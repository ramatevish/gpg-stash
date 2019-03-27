# gpg-stash

A simple in-memory-stash for credentials and other things you'd want to keep safe.

Rather than shipping credentials between computers on a thumbdrive/`scp`, you can instead keep an encrypted tarball that can be passed over an unknown network and decrypted locally to a ramdisk.

The primary motivations for this stash are:

- Security when moving keys and credentials between computers
- Never letting unencrypted keys hit the harddrive
- Easy support for a git-based workflow

## The Workflow

The idea behind this `gpg-stash` is to have a git repository which has a simple script (`run.sh`) to run common tasks, and an encrypted tarball which contains the things you want to safely stash.

When you want to access the stash, it can be decrypted to a ramdisk which won't leave traces the harddrive, and is automatically removed on shutdown.

To add an file to the stash you can decrypt it, add the file to the stash, and re-encrypt the tarball. It can then be commited and pushed so that other computers you use can pull down the latest changes.

## Getting Started

To create the initial tar ball we need two things:

1. the stash directory to encrypt
2. the recipient (you, most likely) to be set

**To set the recipient** (which should be you, as you'll need the private key with the recipient name to decrypt the encrypted tarball), run:

```
./run.sh -m my@privkey.id
```

**To create the initial stash directory**, run:

```
./run.sh -i
```

This will create a directory on a ramdisk which you can load up with anything you want in the initial encrypted tarball.

**To encrypt the files in the stash directory**, run:

```
./run.sh -e
```

which will create/update the encrypted tarball (`stash.tar.gz.gpg`)  with the files you added. This command outputs the list of files added, so ***make sure it's all there.***

**You can remove the stash directory** by removing the ramdisk by running:

```
./run.sh -r
```

**To decrypt the files in the stash directory**, run:

```
./run.sh -d
```

This creates a ramdisk, formats it with APFS, links it locally to `./stash` and extracts the contents of the encrypted tarball into it. 

## Caveat Emptor

This tool is intended to be used by people who have some grasp of OpenPGP and encryption in general.

It's very easy to inadvertantly publish a secret key, encrypt under a key and throw it away, or blow off your leg (cryptographically speaking, hopefully). 

I take no responsibility for your actions, though if you open open up an issue I'm happy to assist the best I can.

### Good ideas (probably)

***- Don't add unencrypted secrets to your commits!***

The `.gitignore` file should take care of this, but do some due diligence when commiting.

***- You should still have password-encrypted keys in the tarball***

Once we decrypt the tarball it's accessible like any other part of the file system, even if it's on a ramdisk.

***- It's best not to expose your tarball publically***

While you're protected by whatever encryption you've configured it's still a fairly large risk - defense in depth includes to not letting your encrypted tarball hit the public internet.

***- If your encryption key is compromised, everything in your encrypted tarball is compromised as well***

This should go without saying, but imagine the case where you lose a key. "Cool, no problem", you say, "I'll just generate a new key and encrypt the tarball under that!" 

While that protects the new tarball, the old one (with your stash contents) can be decrypted with your compromised key.

***- Don't put your prodution DB credentials in your encrypted tarball***

This tool intended for personal keys and if the idea of having *all* the keys to the kingdom in one place that lives on multiple computers doesn't scare you, it should.

A secure host behind a firewall distributing keys to your cloud servers might be a single point of failure but it's a known point of failure and can be sufficiently hardened/audited. This is an encrypted tarball you're using to keep your keys in sync accross your work and personal laptops.

> Defense in depth is your friend
