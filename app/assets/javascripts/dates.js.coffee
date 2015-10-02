(exports ? this).render_date_pickers = ->
	$('.pick_a_date').each (i) ->
		$(this).datetimepicker({
			initialDate: if $('#date_values').length > 0 then $('#date_values').data('initial-date') else new Date(),
			autoclose: true,
			linkField: this.id.replace('_picker', ''),
			linkFormat: 'yyyy-mm-dd',
			format: 'dd.mm.yyyy',
			language: 'de',
			daysOfWeekDisabled: $('#disabled_days_of_week').data('days'),
			minView: 2,
			maxView: 3,
			minuteStep: 30
		})
		.on('changeDate', (e) ->
			$('#selected').data('day', e.date.getDay())
			$('#selected').data('date', e.date.toISOString())
			load_available_days(e.date)
		)
		.on('changeYear', (e) ->
			$('#selected').data('year', e.date.getFullYear())
			load_available_days(e.date)
		)
		.on('changeMonth', (e) ->
			$('#selected').data('month', e.date.getMonth() + 1)
			load_available_days(e.date)
		)

		$('.datetimepicker-days .prev').each (i) ->
			$(this).on('click', (e) ->
				if ($('#selected').data('month') > 1)
					$('#selected').data('month', $('#selected').data('month') - 1)
				else
					$('#selected').data('month', 12)
					$('#selected').data('year', $('#selected').data('year') - 1)

				load_available_days(new Date($('#selected').data('year'), $('#selected').data('month') - 1, 1))
			)

		$('.datetimepicker-days .next').each (i) ->
			$(this).on('click', (e) ->
				if ($('#selected').data('month') < 12)
					$('#selected').data('month', $('#selected').data('month') + 1)
				else
					$('#selected').data('month', 1)
					$('#selected').data('year', $('#selected').data('year') + 1)

				load_available_days(new Date($('#selected').data('year'), $('#selected').data('month') - 1, 1))
			)

		$(this).popover({
			html: true,
			trigger: 'hover',
			content: $('#date_picker_explanation').html()
		})

		load_available_days()

(exports ? this).render_time_pickers = ->
	$('.pick_a_time').each (i) ->
		$(this).timepicker({
            showMeridian: false,
            minuteStep: 30
        })
        .on('changeTime.timepicker', (e) ->
        	weekday = $('#selected').data('day')
        	if (weekday)
        		start_time = $('#time_' + weekday).data('start').replace(':', '')
        		end_time = $('#time_' + weekday).data('end').replace(':', '')
	        	selected_time = e.time.value.replace(':', '')
	        	if selected_time < start_time
	        		$(this).timepicker('setTime', $('#time_' + weekday).data('start'))
	        	if selected_time > end_time
	        		$(this).timepicker('setTime', $('#time_' + weekday).data('end'))
	        	$('#appointment_starts_at_hour').val(e.time.hours)
	        	$('#appointment_starts_at_minute').val(e.time.minutes)
        )

$(document).ready ->
	render_time_pickers()
