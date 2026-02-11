#!/usr/bin/env python3
import json
import os
import random
import string
import uuid
from datetime import datetime, timedelta

import click
import httpx

HOST = os.getenv("DEBUG_HOST", "http://localhost")
PORT = os.getenv("DEBUG_PORT", "8080")
BASE_URL = f"{HOST}:{PORT}"

client = httpx.Client()


# ---- Helpers ----
def rand_name(prefix="Item"):
    return f"{prefix}-{uuid.uuid4().hex[:6]}"


def rand_email():
    return f"{''.join(random.choices(string.ascii_lowercase, k=6))}@example.com"


def rand_amount():
    return random.randint(100, 5000)


def pp(label, data):
    click.echo(click.style(f"\n=== {label} ===", fg="cyan", bold=True))
    click.echo(json.dumps(data, indent=2, ensure_ascii=False))


def create_group(name):
    r = client.post(f"{BASE_URL}/groups", json={"name": name})
    r.raise_for_status()
    return r.json()


def create_member(group_id, name, email):
    r = client.post(
        f"{BASE_URL}/groups/{group_id}/members", json={"name": name, "email": email}
    )
    r.raise_for_status()
    return r.json()


def create_activity(group_id, name):
    start_date = datetime.now() - timedelta(days=random.randint(0, 30))
    end_date = start_date + timedelta(days=random.randint(1, 30))

    payload = {
        "name": name,
        "start_date": start_date.strftime("%Y-%m-%d"),
        "end_date": end_date.strftime("%Y-%m-%d"),
    }

    r = client.post(f"{BASE_URL}/groups/{group_id}/activities", json=payload)
    r.raise_for_status()
    return r.json()


def create_expense(
    group_id,
    activity_id,
    description,
    amount,
    paid_by,
    involved=None,
    currency="JPY",
    equal_split=True,
):
    if involved is None:
        involved = [{"memberId": paid_by, "share": amount}]

    payload = {
        "description": description,
        "amount": amount,
        "currency": currency,
        "paidBy": paid_by,
        "involved": involved,
        "equalSplit": equal_split,
        "date": datetime.now().isoformat() + "Z",
    }

    r = client.post(
        f"{BASE_URL}/groups/{group_id}/activities/{activity_id}/expenses", json=payload
    )
    r.raise_for_status()
    return r.json()


def settle(group_id, activity_id):
    r = client.post(
        f"{BASE_URL}/groups/{group_id}/activities/{activity_id}/settle",
        json={},
    )
    r.raise_for_status()
    return r.json()


def update_group(group):
    payload = {"name": rand_name("GroupUpdated")}
    return client.put(f"{BASE_URL}/groups/{group['id']}", json=payload).json()


def update_member(group_id, member):
    payload = {"name": rand_name("MemberUpdated")}
    return client.put(
        f"{BASE_URL}/groups/{group_id}/members/{member['id']}", json=payload
    ).json()


def update_activity(group_id, activity):
    payload = {"name": rand_name("ActivityUpdated")}
    return client.put(
        f"{BASE_URL}/groups/{group_id}/activities/{activity['id']}", json=payload
    ).json()


def update_expense(group_id, activity_id, expense, involved=None, equal_split=True):
    if involved is None:
        involved = [{"memberId": expense.get("paidBy"), "share": expense.get("amount")}]

    payload = {
        "description": rand_name("ExpenseUpdated"),
        "amount": expense["amount"],
        "currency": expense["currency"],
        "paidBy": expense["paidBy"],
        "involved": involved,  # shares ignored for equal split
        "equalSplit": equal_split,
        "date": datetime.now().isoformat() + "Z",
    }
    return client.put(
        f"{BASE_URL}/groups/{group_id}/activities/{activity_id}/expenses/{expense['id']}",
        json=payload,
    ).json()


def patch_settlement_paid(group_id, activity_id, settlement_id, paid: bool):
    payload = {"paid": paid}
    r = client.patch(
        f"{BASE_URL}/groups/{group_id}/activities/{activity_id}/settlements/{settlement_id}",
        json=payload,
    )
    r.raise_for_status()
    return r.json()


# ---- CLI ----
@click.group()
@click.option("--base-url", default=BASE_URL, help="Base URL of the API server")
def cli(base_url):
    """Tiny CLI for seeding, updating, and clearing the API."""
    global BASE_URL
    BASE_URL = base_url


@cli.command()
@click.option("--count", default=1, help="Number of groups to seed")
def seed(count):
    """Create random data for all resources."""
    click.secho(f"Seeding {count} groups...", fg="green")

    for _ in range(count):
        group = create_group(rand_name("Group"))
        pp("Group created", group)

        member1 = create_member(group["id"], rand_name("Alice"), rand_email())
        member2 = create_member(group["id"], rand_name("Bob"), rand_email())
        pp("Members created", [member1, member2])

        activity = create_activity(group["id"], rand_name("Activity"))
        pp("Activity created", activity)

        expense1 = create_expense(
            group["id"],
            activity["id"],
            rand_name("Hotel"),
            rand_amount(),
            member1["id"],
            involved=[{"memberId": member1["id"]}, {"memberId": member2["id"]}],
            equal_split=True,
        )

        amount2 = rand_amount()
        expense2 = create_expense(
            group["id"],
            activity["id"],
            rand_name("Dinner"),
            amount2,
            member2["id"],
            involved=[
                {"memberId": member1["id"], "share": amount2 * 0.6},
                {"memberId": member2["id"], "share": amount2 * 0.4},
            ],
            equal_split=False,
        )

        pp("Expenses created", [expense1, expense2])

        settlement = settle(group["id"], activity["id"])
        pp("Settlement created", settlement)


@cli.command()
def update():
    """Randomly update first found instance of each resource."""
    click.secho("Updating first found resources with random values...", fg="yellow")

    groups = client.get(f"{BASE_URL}/groups").json()
    if not groups:
        click.secho("No groups found. Run `seed` first.", fg="red")
        return

    g = groups[0]
    ug = update_group(g)
    pp("Updated group", ug)

    members = client.get(f"{BASE_URL}/groups/{g['id']}/members").json()
    if members:
        m = members[0]
        um = update_member(g["id"], m)
        pp("Updated member", um)

    activities = client.get(f"{BASE_URL}/groups/{g['id']}/activities").json()
    if activities:
        a = activities[0]
        ua = update_activity(g["id"], a)
        pp("Updated activity", ua)

        expenses = client.get(
            f"{BASE_URL}/groups/{g['id']}/activities/{a['id']}/expenses"
        ).json()
        if expenses:
            e = expenses[0]
            e["amount"] = rand_amount()
            shares = [random.random() for _ in members]
            total = sum(shares)
            # scale shares to match expense amount exactly
            shares = [s / total * e["amount"] for s in shares]
            involved = [
                {"memberId": m["id"], "share": s} for m, s in zip(members, shares)
            ]
            ue = update_expense(g["id"], a["id"], e, involved, False)
            pp("Updated expense", ue)

        settlements = client.get(
            f"{BASE_URL}/groups/{g['id']}/activities/{a['id']}/settlements"
        ).json()
        if settlements:
            s = settlements[0]
            us = patch_settlement_paid(g["id"], a["id"], s["id"], True)
            pp("Updated settlement paid", us)


@cli.command()
def clear():
    """Delete all resources."""
    click.secho("Clearing all resources...", fg="red")

    groups = client.get(f"{BASE_URL}/groups").json()
    for g in groups:
        gid = g["id"]

        activities = client.get(f"{BASE_URL}/groups/{gid}/activities").json()
        for a in activities:
            settlements = client.get(
                f"{BASE_URL}/groups/{gid}/activities/{a['id']}/settlements"
            ).json()
            for s in settlements:
                client.delete(
                    f"{BASE_URL}/groups/{gid}/activities/{a['id']}/settlements/{s['id']}"
                )

            expenses = client.get(
                f"{BASE_URL}/groups/{gid}/activities/{a['id']}/expenses"
            ).json()
            for e in expenses:
                client.delete(
                    f"{BASE_URL}/groups/{gid}/activities/{a['id']}/expenses/{e['id']}"
                )

            client.delete(f"{BASE_URL}/groups/{gid}/activities/{a['id']}")

        members = client.get(f"{BASE_URL}/groups/{gid}/members").json()
        for m in members:
            client.delete(f"{BASE_URL}/groups/{gid}/members/{m['id']}")

        client.delete(f"{BASE_URL}/groups/{gid}")


if __name__ == "__main__":
    cli()
