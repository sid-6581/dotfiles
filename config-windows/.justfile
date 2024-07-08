set positional-arguments

alias c := clean
alias ugr := update-git-repos

noop:

ahk:
  #!pwsh
  "$env:APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/Keys.ahk"

[confirm]
clean:
  -pskill -t neovide
  -pskill -t nvim
  -pskill -t git
  -rm -rf $LOCALAPPDATA/Temp/nvim
  -rm -rf $LOCALAPPDATA/Temp/test-packages
  -rm -rf $LOCALAPPDATA/nvim-data
  -rm -rf $LOCALAPPDATA/nvim/lazy-lock.json

update-pip:
  #!pwsh
  pip freeze | %{$_.split('==')[0]} | %{pip install --upgrade $_}

update-git-repos:
  #!pwsh
  Get-ChildItem -Directory -Force -Recurse *.git | ForEach-Object { cd $_.Parent.FullName; Write-Host $_.Parent.FullName; git pull }

bob-use version:
  #!pwsh
  Import-VisualStudioVars -Architecture x64 | Out-Null
  bob use {{ version }}

nvim-release:
  #!pwsh
  Import-VisualStudioVars -Architecture x64
  cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=Release
  cmake --build .deps --config Release
  cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=Release
  cmake --build build --config Release

nvim-install:
  #!pwsh
  Import-VisualStudioVars -Architecture x64
  cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=Release
  cmake --build .deps --config Release
  cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=Release
  cmake --build build --config Release
  cmake --install build --prefix "C:\nvim"

nvim-debug:
  #!pwsh
  Import-VisualStudioVars -Architecture x64
  cmake -S cmake.deps -B .deps -G Ninja -D CMAKE_BUILD_TYPE=Debug
  cmake --build .deps
  cmake -B build -G Ninja -D CMAKE_BUILD_TYPE=Debug
  cmake --build build

nvim-clean:
  #!pwsh
  Import-VisualStudioVars -Architecture x64
  make distclean

nvim-test:
  #!pwsh
  Import-VisualStudioVars -Architecture x64
  $env:CMAKE_BUILD_TYPE="Release"; make test

nvim-test-debug:
  #!pwsh
  Import-VisualStudioVars -Architecture x64
  $env:CMAKE_BUILD_TYPE="Debug"; make test
