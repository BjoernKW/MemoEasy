(exports ? this).load_available_weekdays = () ->
	$.ajax({
		url: '/slots/list_available_weekdays.json',
		type: 'GET',
		data: {
			'blocker': $('#slot_blocker').is(':checked'),
		},
		dataType: 'json',
		success: (data)  ->
			$('#slot_weekday').html('')
			option = $('<option/>')
			option.html($('#default_labels').data('please-choose'))
			$('#slot_weekday').append(option)
			
			$(data).each( ->
				option = $('<option/>')
				option.attr('value', this.id)
				option.html(this.name)
				$('#slot_weekday').append(option)
			)
			$('#slot_weekday').prop('selectedIndex', 0);
			
			$('#slot_weekday').trigger('liszt:updated')
	})

$(document).ready ->
	$('#slot_blocker').on('click', (e) ->
		load_available_weekdays()
	)