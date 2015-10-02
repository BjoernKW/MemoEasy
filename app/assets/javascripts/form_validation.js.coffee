(exports ? this).process_error_messages = (evt, xhr, status, error, entity_name) ->
	response = JSON.parse(xhr.responseText)
	$.each(response, (field_key, field_values) ->
		error_list = $('<ul/>')

		selector = '#' + field_key + '_errors'
		unless $(selector).length > 0
			attribute_name_parts = field_key.split('.')
			selector = '.new_' + attribute_name_parts[0] + ' #' + attribute_name_parts[1] + '_errors'
		
		$(selector).html(error_list)
		$.each(field_values, (error_message_key, error_message_value) ->
			error_list.append($('<li/>', { html: error_message_value }))
		)

		$(selector).show()
		$('#' + entity_name + '_' + field_key).parent().parent().addClass('error')
	)

(exports ? this).reset_error_messages = (entity) ->
	$(entity).find('.error_messages').hide()
	$(entity).find('.control-group').removeClass('error')
