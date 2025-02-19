## Projects
[] create_app_users(display_names, forms=None, project_id=None)

[x] get(project_id=None)

[x] list()

## Submissions
[] add_comment(instance_id, comment, project_id=None, form_id=None)

[] create(xml, form_id=None, project_id=None, device_id=None, encoding='utf-8')

[] edit(instance_id, xml, form_id=None, project_id=None, comment=None, encoding='utf-8')

[] get(instance_id, form_id=None, project_id=None)

[] get_table(form_id=None, project_id=None, table_name='Submissions', skip=None, top=None, count=None, wkt=None, filter=None, expand=None, select=None)

[] list(form_id=None, project_id=None)

[] list_comments(instance_id, form_id=None, project_id=None)

[] review(instance_id, review_state, form_id=None, project_id=None, comment=None)

## Forms
[] create(definition, attachments=None, ignore_warnings=True, form_id=None, project_id=None)

[] get(form_id, project_id=None)

[] list(project_id=None)

[] update(form_id, project_id=None, definition=None, attachments=None, version_updater=None)

## Entities
[] create(label, data, entity_list_name=None, project_id=None, uuid=None)

[] create_many(data, entity_list_name=None, project_id=None, create_source=None, source_size=None)

[] delete(uuid, entity_list_name=None, project_id=None)

[] get_table(entity_list_name=None, project_id=None, skip=None, top=None, count=None, filter=None, select=None)

[] list(entity_list_name=None, project_id=None)

[] merge(data, entity_list_name=None, project_id=None, match_keys=None, add_new_properties=True, update_matched=True, delete_not_matched=False, source_label_key='label', source_keys=None, create_source=None, source_size=None)

[] update(uuid, entity_list_name=None, project_id=None, label=None, data=None, force=None, base_version=None) 

## Entity Lists¶
[] create(approval_required=False, entity_list_name=None, project_id=None)

[] get(entity_list_name=None, project_id=None)

[] list(project_id=None)