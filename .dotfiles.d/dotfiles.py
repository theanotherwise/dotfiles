import os
import sys
import shutil
import yaml
import random
import string
import requests
import re
import tarfile
import lzma
import zipfile
import getpass
import platform
import datetime
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed

SYSTEM_CONFIG = {
    "Darwin": "macos.yaml",
    "Linux": "linux.yaml"
}

PKG_TYPES = {
    'binary': "binary",
    'zip': "zip",
    'tar_gz': "tar.gz",
    'tar_xz': "tar.xz"
}

RANDOM_STRING = ''.join(random.choices(string.ascii_lowercase + string.digits, k=12))
TMP_PATH = "/tmp/dotfiles-{}".format(RANDOM_STRING)
LOG_LOCK = threading.Lock()

active_user = getpass.getuser()
config_name = SYSTEM_CONFIG[platform.system()]

with open(os.path.dirname(__file__) + "/{0}".format(config_name), "r") as file:
    CONFIG = yaml.load(file, Loader=yaml.FullLoader)


class Package:
    def __init__(self, name, versions, latest, skipped_versions):
        self.name = name
        self.versions = versions
        self.latest = latest
        self.skipped_versions = skipped_versions


class PackageVersion:
    def __init__(self, version, _type, url, ext, override, strip, in_bin):
        self.version = version
        self.type = _type
        self.ext = ext
        self.url = url.format(version=version)
        self.filename = None
        self.override = override
        self.strip = strip
        self.in_bin = in_bin

    def set_filename(self, filename):
        self.filename = filename


def dir_exists(path):
    return os.path.exists(path) and os.path.isdir(path)


def timestamp():
    return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def log_event(status, **fields):
    parts = ["{}={}".format(key, value) for key, value in fields.items() if value is not None]
    with LOG_LOCK:
        print("[{}] setup {:<8} {}".format(timestamp(), status, " ".join(parts)).rstrip(), flush=True)


def alternative_key(data, key, alert):
    return data[key] if key in data else alert


def key_exists_none(data, key):
    return data[key] if data.get(key) else None


def parse_extension(url):
    if re.match(r".*\.tar\.gz$", url):
        return "tar.gz"
    elif re.match(r".*zip$", url):
        return "zip"
    elif re.match(r".*\.tar\.xz$", url):
        return "tar.xz"
    else:
        return "bin"


def setup():
    if os.path.exists(TMP_PATH):
        sys.exit("Directory exists '{}'..".format(TMP_PATH))
    else:
        os.makedirs(TMP_PATH)


def download(package, v):
    response = requests.get(v.url)
    response.raise_for_status()

    if v.ext == 'bin':
        filename = "{}-{}".format(package.name, v.version)
    else:
        filename = "{}-{}.{}".format(package.name, v.version, v.ext)

    with open("{}/{}".format(TMP_PATH, filename), "wb") as _file:
        v.set_filename(filename)
        _file.write(response.content)


def copy_binary(bin_path, ver_path):
    shutil.move(bin_path, ver_path)


def extract_tar_strip(tar_path, dest_path, _type):
    if _type == PKG_TYPES['tar_gz']:
        with tarfile.open(tar_path, "r:gz") as tar:
            for member in tar.getmembers():
                member.name = "/".join(member.name.split("/")[1:])
                tar.extract(member, path=dest_path)
    elif _type == PKG_TYPES['tar_xz']:
        with lzma.open(tar_path, "rb") as xz_file:
            with tarfile.open(fileobj=xz_file, mode="r") as tar:
                for member in tar.getmembers():
                    member.name = "/".join(member.name.split("/")[1:])
                    tar.extract(member, path=dest_path)


def extract_tar_non_strip(tar_path, dest_path, _type):
    if _type == PKG_TYPES['tar_gz']:
        with tarfile.open(tar_path, "r:gz") as tar:
            tar.extractall(path=dest_path)
    elif _type == PKG_TYPES['tar_xz']:
        with lzma.open(tar_path, "rb") as xz_file:
            with tarfile.open(fileobj=xz_file, mode="r") as tar:
                tar.extractall(path=dest_path)


def extract_tar(tar_path, dest_path, strip, _type):
    if strip:
        extract_tar_strip(tar_path, dest_path, _type)
    else:
        extract_tar_non_strip(tar_path, dest_path, _type)


def extract_zip_strip(zip_path, dest_path):
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        for member in zip_ref.infolist():
            if member.is_dir():
                continue

            extracted_path = os.path.join(*member.filename.split('/')[1:])

            output_path = os.path.join(dest_path, extracted_path)

            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            with zip_ref.open(member) as source, open(output_path, "wb") as target:
                shutil.copyfileobj(source, target)


def extract_zip_non_strip(zip_path, dest_path):
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(dest_path)


def extract_zip(zip_path, dest_path, strip):
    if strip:
        extract_zip_strip(zip_path, dest_path)
    else:
        extract_zip_non_strip(zip_path, dest_path)


def if_in_bin_dir(version_path, in_bin):
    if not in_bin:
        return "{}/bin".format(version_path)
    else:
        return version_path


def setup_permissions(directory_path):
    for dirpath, dirnames, filenames in os.walk(directory_path):
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            os.chmod(file_path, 0o755)


def extract(package, v, ver_path):
    if ver_path:
        if v.type == PKG_TYPES['binary']:
            new_bin_path = "{}/{}".format(TMP_PATH, v.filename)
            new_ver_path = if_in_bin_dir(ver_path, v.in_bin)

            copy_binary(new_bin_path, "{}/{}".format(new_ver_path, package.name))
        elif v.type == PKG_TYPES['zip']:
            new_bin_path = "{}/{}".format(TMP_PATH, v.filename)
            new_ver_path = if_in_bin_dir(ver_path, v.in_bin)

            extract_zip(new_bin_path, new_ver_path, v.strip)
        elif v.type == PKG_TYPES['tar_gz'] or v.type == PKG_TYPES['tar_xz']:
            new_bin_path = "{}/{}".format(TMP_PATH, v.filename)
            new_ver_path = if_in_bin_dir(ver_path, v.in_bin)

            extract_tar(new_bin_path, new_ver_path, v.strip, v.type)
        else:
            sys.exit("Unrecognized format '{}'".format(v.type))

        setup_permissions("{}/bin".format(ver_path))


def recursive_remove(_path):
    shutil.rmtree(_path)


def versioning(versions, url, _type, override, name, strip, in_bin):
    arr = []
    skipped = []

    for i in versions:
        new_url = alternative_key(i, 'url', url)
        new_type = alternative_key(i, 'type', _type)
        new_override = alternative_key(i, 'override', override)
        new_strip = alternative_key(i, 'strip', strip)
        new_in_bin = alternative_key(i, 'inBin', in_bin)
        new_ext = parse_extension(new_url)

        version_path = "{}/{}/{}".format(CONFIG['target_dir'].format(user=active_user), name, i['version'])

        if dir_exists(version_path) and new_override:
            recursive_remove(version_path)
            arr.append(PackageVersion(i['version'], new_type, new_url, new_ext, new_override, new_strip, new_in_bin))
        elif not dir_exists(version_path):
            arr.append(PackageVersion(i['version'], new_type, new_url, new_ext, new_override, new_strip, new_in_bin))
        else:
            skipped.append(i['version'])

    return arr, skipped


def package_versions():
    arr = []

    for i in CONFIG['binaries']:
        versions, skipped = versioning(i['versions'], i['url'], i['type'], i['override'], i['name'], i['strip'], i['inBin'])
        arr.append(Package(i['name'], versions, i['latest'], skipped))

    return arr


def mkdir_package(name):
    package_path = "{}/{}".format(CONFIG['target_dir'].format(user=active_user), name)
    os.makedirs(package_path, exist_ok=True)

    return package_path


def make_package_version(package_path, version):
    version_path = "{}/{}".format(package_path, version)
    binary_path = "{}/bin".format(version_path)

    os.makedirs(binary_path, exist_ok=True)
    return version_path


def make_symlink(package_path, package_version):
    link_path = "{}/latest".format(package_path)
    source_path = "{}/{}".format(package_path, package_version)

    try:
        os.unlink(link_path)
    except OSError as e:
        pass

    os.symlink(source_path, link_path)


def setup_jobs():
    value = os.environ.get("SC_DOTFILES_SETUP_JOBS", "6")
    try:
        jobs = int(value)
    except ValueError:
        jobs = 6

    return max(1, jobs)


def fetch_package(p):
    package_path = mkdir_package(p.name)
    installed = 0

    for v in p.versions:
        version_path = make_package_version(package_path, v.version)
        log_event("fetch", tool=p.name, version=v.version, file="{}/{}".format(TMP_PATH, "{}-{}.{}".format(p.name, v.version, v.ext) if v.ext != "bin" else "{}-{}".format(p.name, v.version)))
        download(p, v)
        log_event("install", tool=p.name, version=v.version, path=version_path)
        extract(p, v, version_path)
        installed += 1

    make_symlink(package_path, p.latest)
    log_event("link", tool=p.name, latest=p.latest, path="{}/latest".format(package_path))

    return installed


def fetch_packages(packages):
    pending = [p for p in packages if p.versions]
    skipped_versions = sum(len(p.skipped_versions) for p in packages)
    pending_versions = sum(len(p.versions) for p in packages)

    for p in packages:
        if p.skipped_versions:
            log_event("skip", tool=p.name, versions=",".join(p.skipped_versions), path="{}/{}".format(CONFIG['target_dir'].format(user=active_user), p.name))

    if not pending:
        return 0, skipped_versions

    workers = min(setup_jobs(), len(pending))
    log_event("parallel", jobs=workers, tools=len(pending), versions=pending_versions)

    installed = 0
    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = [executor.submit(fetch_package, package) for package in pending]
        for future in as_completed(futures):
            installed += future.result()

    return installed, skipped_versions


def cleanup():
    recursive_remove(TMP_PATH)


def main():
    packages = package_versions()
    log_event("start", platform=platform.system(), config=config_name, target=CONFIG['target_dir'].format(user=active_user), tmp=TMP_PATH)
    setup()
    try:
        installed, skipped = fetch_packages(packages)
        log_event("done", installed=installed, skipped=skipped)
    finally:
        cleanup()


if __name__ == "__main__":
    main()
