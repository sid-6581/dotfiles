# Rate arch mirrors and update mirrorlist.
export def rate-mirrors [] {
  let mirrors = ^rate-mirrors arch
  $mirrors | ^sudo tee /etc/pacman.d/mirrorlist | ignore
  let mirrors = ^rate-mirrors endeavouros
  $mirrors | ^sudo tee /etc/pacman.d/endeavouros-mirrorlist | ignore
}
