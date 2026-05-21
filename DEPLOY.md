# Deployment

The site deploys to the EC2/Caddy web root:

`/var/www/americanbuiltcnc`

## Local auto deploy on commit

This machine is configured with:

```bash
git config core.hooksPath .githooks
```

After each local commit, `.githooks/post-commit` runs `scripts/deploy-local.ps1`, which deploys `index.html` and `thankyou.html` using the WSL SSH key:

`/home/ctan/.ssh/dareeat-key.pem`

## GitHub Actions deploy on push

`.github/workflows/deploy.yml` deploys on every push to `master`.

Required GitHub secret:

- Name: `EC2_SSH_KEY`
- Value: full contents of `/home/ctan/.ssh/dareeat-key.pem`

Add it at:

`GitHub repo > Settings > Secrets and variables > Actions > New repository secret`

Do not commit the key into the repo or paste it into chat.

After the secret is added, re-run the failed workflow or push a new commit.
