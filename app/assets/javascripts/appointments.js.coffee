(exports ? this).show_new_customer = ->
	$('.existing_customer').hide()
	$('.existing_customer select').each( ->
		$(this).attr('disabled', 'disabled')
	)
	$('#appointment_customer_attributes_id').val('')

	$('.new_customer').show()
	$('.new_customer input').each( ->
		$(this).removeAttr('disabled')
	)
	$('.new_customer_label').show()

	$('#appointment_show_new_customer').val('true')

(exports ? this).show_new_service = ->
	$('.existing_service').hide()
	$('.existing_service select').each( ->
		$(this).attr('disabled', 'disabled')
	)
	$('#appointment_service_attributes_id').val('')

	$('.new_service').show()
	$('.new_service input').each( ->
		$(this).removeAttr('disabled')
	)
	$('.new_service_label').show()

	$('#appointment_show_new_service').val('true')

(exports ? this).show_new_staff_member = ->
	$('.existing_staff_member').hide()
	$('.existing_staff_member select').each( ->
		$(this).attr('disabled', 'disabled')
	)
	$('#appointment_staff_member_attributes_id').val('')

	$('.new_staff_member').show()
	$('.new_staff_member input').each( ->
		$(this).removeAttr('disabled')
	)
	$('.new_staff_member_label').show()

	$('#appointment_staff_member_attributes_colour').colorpicker({
		format: 'hex'
	})

	$('#appointment_show_new_staff_member').val('true')

(exports ? this).decorate_buttons = ->
	$('.new_customer_button').bind('click', ->
		show_new_customer()
	)

	$('.new_service_button').bind('click', ->
		show_new_service()
	)

	$('.new_staff_member_button').bind('click', ->
		show_new_staff_member()
	)

(exports ? this).load_available_staff_members = (starts_at, starts_at_hour, starts_at_minute) ->
	$.ajax({
		url: '/staff_members/list_available.json',
		type: 'GET',
		data: {
			'starts_at': starts_at,
			'starts_at_hour': starts_at_hour,
			'starts_at_minute': starts_at_minute,
			'service_id': $('#appointment_service_id').val(),
			'company_id': $('#company').data('id'),
			'staff_member_id': $('#appointment_staff_member_id').val()
		},
		dataType: 'json',
		success: (data)  ->
			appointment_available = false

			$('#appointment_staff_member_id').html('')
			$('#appointment_staff_member_id').append($('<option/>'))
			$(data).each( ->
				option = $('<option/>')
				unless appointment_available
					option.attr('selected', 'selected') # select first staff member
				option.attr('value', this.id)
				option.html(this.name)
				$('#appointment_staff_member_id').append(option)

				appointment_available = true
			)
			$('#appointment_staff_member_id').trigger('liszt:updated')
			
			unless appointment_available
				$('#appointment_not_available').show()
			else
				$('#appointment_not_available').hide()
	})

(exports ? this).load_available_time_slots = () ->
	$.ajax({
		url: '/staff_members/list_available_time_slots.json',
		type: 'GET',
		data: {
			'service_id': $('#appointment_service_id').val(),
			'company_id': $('#company').data('id'),
			'staff_member_id': $('#appointment_staff_member_id').val(),
			'date': $('#selected').data('date')
		},
		dataType: 'json',
		success: (data)  ->
			$('#starts_at_time_slots').html('')
			$(data).each( ->
				date = new Date()
				date.setISO8601(this)

				slot_element = $('<li/>')
				slot_element.addClass('slot_element alert alert-success')
				slot_element.html(date.toString('HH:mm'))
				slot_element.data('starts-at', this)

				slot_element.on('click', (e) ->
					select_time(this)
				)

				$('#starts_at_time_slots').append(slot_element)
			)
	})

(exports ? this).load_available_days = (current_date = new Date($('#appointment_starts_at').val())) ->
	$.ajax({
		url: '/companies/list_available_days.json',
		type: 'GET',
		data: {
			'service_id': $('#appointment_service_id').val(),
			'company_id': $('#company').data('id'),
			'staff_member_id': $('#appointment_staff_member_id').val(),
			'year': current_date.getFullYear(),
			'month': current_date.getMonth() + 1
		},
		dataType: 'json',
		success: (data)  ->
			$('#appointment_starts_at_calendar .datetimepicker-days td').each( ->
				unless $(this).hasClass('new') || $(this).hasClass('old') || $(this).hasClass('disabled')
					if data[$(this).html()] == 'available'
						$(this).addClass('alert alert-success')
					else if data[$(this).html()] == 'few_left'
						if $('#logged_in_user').data('id') != 0
							$(this).addClass('alert')
						else
							$(this).addClass('alert alert-success')
					else
						$(this).addClass('alert alert-error')
			)
	})

(exports ? this).decorate_calendar_boxes = ->
	$('#calendar td a').bind('ajax:beforeSend', ->
		$('#day_indicator').spin('large', '#7ac143')
	)
	.bind('ajax:success', (evt, data, status, xhr) ->
		response = JSON.parse(xhr.responseText)
		$('#appointments_today').html(response['appointments_today_partial'])
	)
	.bind('ajax:complete', ->
		$('#day_indicator').spin(false)
	)

(exports ? this).select_time = (slot_element) ->
	$('#appointment_starts_at_time').val($(slot_element).data('starts-at'))
	$('.slot_element').removeClass('alert-info')
	$(slot_element).addClass('alert-info')

$(document).ready ->
	render_date_pickers()
	decorate_buttons()
	decorate_calendar_boxes()

	initialDate = if $('#date_values').length > 0 then $('#date_values').data('initial-date') else new Date()
	$('#selected').data('date', initialDate)

	if $('#appointment_show_new_customer').val() == 'true'
		show_new_customer()

	if $('#appointment_show_new_service').val() == 'true'
		show_new_service()
	else
		$('#appointment_service_id').chosen().change( ->
			load_available_time_slots()
		)
		
	if $('#appointment_show_new_staff_member').val() == 'true'
		show_new_staff_member()
	else
		$('#appointment_staff_member_id').chosen().change( ->
			load_available_time_slots()
		)

	$('#appointment_starts_at_calendar').on('changeDate', (e) ->
		load_available_time_slots()
	)

	$('#appointment_starts_at_picker').on('change', (e) ->
		date = Date.parse($(this).val())
		date.add(1).day()

		$('#selected').data('day', date.getDay())
		$('#selected').data('month', date.getMonth() + 1)
		$('#selected').data('year', date.getFullYear())
		$('#selected').data('date', date.toISOString())

		load_available_time_slots()
	)

	$('.slot_element').on('click', (e) ->
		select_time(this)
	)

	$('#recurring_appointment').popover({
		html: true,
		trigger: 'hover',
		content: $('#repeat_explanation').html()
	})
