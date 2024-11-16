function toggleLayer() {
  const layer = document.getElementById("layer");
  if (layer.classList.contains("hidden")) {
    layer.classList.remove("hidden");
  } else {
    layer.classList.add("hidden");
  }
}
