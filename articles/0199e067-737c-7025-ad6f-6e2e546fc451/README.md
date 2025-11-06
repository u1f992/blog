## マシンのグローバルIPアドレスを定期的に特定のGistにアップロードする

<figure>
<figcaption>upload-public-ip.sh</figcaption>

```sh
#!/bin/sh -eu

# - `Settings > Developer settings > Personal access tokens > Fine-grained tokens > Generate new token`
#   - `Repository access > Public repositories`
#   - `Permissions > Account > Add permissions > Gist`
TOKEN="github_pat"
GIST_ID="gist_id"
HOSTNAME="$(/bin/hostname)"
SAFE_HOSTNAME="$(/bin/echo "${HOSTNAME}" | /bin/tr --complement --delete 'A-Za-z0-9._-')"
FILENAME="${SAFE_HOSTNAME}-public-ip.txt"
IP="$(/bin/curl --fail --silent --show-error https://checkip.amazonaws.com | /bin/tr --delete '\n')"
DESC="Public IP updated at $(/bin/date --utc +%Y-%m-%dT%H:%M:%SZ) on ${HOSTNAME}"

# https://docs.github.com/en/rest/gists/gists?apiVersion=2022-11-28#update-a-gist
/bin/curl --fail --silent --show-error \
  --request PATCH \
  --header "Accept: application/vnd.github+json" \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/gists/${GIST_ID}" \
  --data "{\"description\":\"${DESC}\",\"files\":{\"${FILENAME}\":{\"content\":\"${IP}\n\"}}}"
```

</figure>

```
$ crontab -e

# 末尾に追記：
# */30 * * * * /home/mukai/upload-public-ip.sh >> /home/mukai/upload-public-ip.log 2>&1
```

別解として[glotlabs/gdrive](https://github.com/glotlabs/gdrive)でGoogle Driveにアップロードする方法もあるが、セットアップ手順が少し面倒。

- [自宅のグローバルIPアドレスを外出先で知る #RDP - Qiita](https://qiita.com/itagagaki/items/7720d0632f9fd9c78673)
