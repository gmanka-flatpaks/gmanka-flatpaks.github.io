import urllib.request
import dulwich.client
import dulwich.porcelain
import pathlib
import yaml
import rich
import json
import os


class templates:
    x86_64 = {
        'runner': 'ubuntu-24.04',
        'arch': 'x86_64',
    }
    aarch64 = {
        'runner': 'ubuntu-24.04-arm',
        'arch': 'aarch64',
    }
    default = {
        'type': 'app',
        'branch': 'master',
    }

class config:
    org_name: str = 'gmanka-flatpaks'
    org_url: str = f'https://github.com/{org_name}'
    state_url: str = f'https://raw.githubusercontent.com/{org_name}/state/refs/heads/main/state.yml'
    to_build: list[dict] = []
    to_push: list[dict] = []
    packages: list[dict]
    state: dict


class paths:
    repo: pathlib.Path = pathlib.Path(__file__).parent.parent.parent.resolve()
    checkstate: pathlib.Path = pathlib.Path(__file__).parent.resolve()
    configs: pathlib.Path = repo / 'configs'
    packages_file: pathlib.Path = configs / 'packages.yml'
    state_file: pathlib.Path = configs / 'state.yml'


def get_repo_url(
    package: dict
) -> str:
    repo_url: str = package.get('repo_url', '')
    package_id = package['id']
    if repo_url:
        return repo_url
    else:
        return f'{config.org_url}/{package_id}'


def get_commit(
    repo_url: str
) -> str:
    client, path = dulwich.client.get_transport_and_path(repo_url)
    refs = client.get_refs(
        path.encode()
    ).refs
    assert refs
    return refs[b'HEAD'].decode('ascii')


def outdated(
    package: dict,
    repo_url: str,
    commit_new: str,
):
    for key, value in templates.default.items():
        if key not in package:
            package[key] = value
    config.to_push.append(package | {'commit': commit_new})
    match package.get('arch', ''):
        case 'x86_64':
            package['runner'] = 'ubuntu-24.04'
            config.to_build.append(package)
        case 'aarch64':
            package['runner'] = 'ubuntu-24.04-arm'
            config.to_build.append(package)
        case _:
            config.to_build += [
                package | templates.x86_64,
                package | templates.aarch64,
            ]


def parse_package(
    package: dict
) -> None:
    repo_url = get_repo_url(package)
    commit_new = get_commit(repo_url)
    package_id = package['id']
    commit_old = config.state.get(package_id, '')
    if commit_new == commit_old:
        rich.print(f'[green]ok[/]: {repo_url}')
    else:
        rich.print(f'[red]outdated[/]: {repo_url}')
        outdated(package, repo_url, commit_new)


def main() -> None:
    urllib.request.urlretrieve(
        url=config.state_url,
        filename=paths.state_file,
    )
    with paths.packages_file.open() as f:
        config.packages = yaml.safe_load(f)
    with open(paths.state_file) as f:
        config.state = yaml.safe_load(f)
    for package in config.packages:
        parse_package(package)
    with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
        f.write(f'to_build={json.dumps(config.to_build)}\n')
        f.write(f'to_push={json.dumps(config.to_push)}\n')


main()
