# Rate arch mirrors and update mirrorlist.
export def rate-mirrors [] {
  let mirrors = (^rate-mirrors arch --max-delay=43200)
  $mirrors | ^sudo tee /etc/pacman.d/mirrorlist | null
}
