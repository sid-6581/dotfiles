# Lists available local ollama models.
export def "ollama models" [] {
  http get --headers ["Authorization" $"Bearer ($env.OPEN_WEBUI_API_KEY)"] $"($env.OPEN_WEBUI_URL)/ollama/api/tags"
  | get models
  | reject digest urls
  | update modified_at { into datetime }
  | update size { into filesize }
}

# Lists running ollama models.
export def "ollama running" [] {
  http get --headers ["Authorization" $"Bearer ($env.OPEN_WEBUI_API_KEY)"] $"($env.OPEN_WEBUI_URL)/ollama/api/ps"
  | values
  | get models.0
  | reject digest
  | update expires_at { into datetime }
  | update size { into filesize }
  | update size_vram { into filesize }
}
