Set-PSReadLineOption -EditMode Emacs

# 解决 pwsh 在 ssh 下不生效的问题
$DockerPath = "C:\Program Files\Docker\Docker\resources\bin"
if ($env:Path -notlike "*$DockerPath*") {
    $env:Path += ";$DockerPath"
}
