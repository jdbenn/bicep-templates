az stack sub create \
  --name 'data-pros-database' \
  --location 'centralus' \
  --template-file main.bicep \
  --parameters @main.json \
  --action-on-unmanage deleteAll \
  --deny-settings-mode none
