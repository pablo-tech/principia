# <tenant> — context

<One paragraph: whose work this is, and what this repository is for.>

**The protocol — how work is done here — is [`protocol/AGENTS.md`](protocol/AGENTS.md).** It is
shared, tenant-free and maintained elsewhere. Read it first. Nothing below restates any of it: a
copy would drift, and then two files would disagree with no signal which is current.

Everything below is true of this tenant alone.

## Repositories

<Which repository owns what. Check here before creating a folder for new material.>

| Repository | Clone | Holds |
|---|---|---|
| | | |

## Credentials

<Where real credentials live — which is not this repository. See
[`protocol/guards/credentials-guard.sh`](protocol/guards/credentials-guard.sh), which refuses them
at commit time.>

## Machines

<What a machine needs before it can do this work, and where the runbook is.>

## Tenancy

The tenants this repository is **not** are declared in [`.protocol/tenant`](.protocol/tenant), and a
commit naming one is refused. Add a tenant there when you take one on — not to this file.

The identities this repository's commits may be made as are declared in `.protocol/identity`, and a
commit made as another is refused — **if this repository carries that file**, which the installer
deliberately does not create. A clone carries no identity of its own, so a machine's default is what
a commit here would otherwise be made as, and until somebody decides, that is the answer. Copy
`protocol/tenant-template/.protocol/identity` in and fill it in to decide: carrying it is how a
repository opts in, so an empty one refuses every commit rather than policing none.
