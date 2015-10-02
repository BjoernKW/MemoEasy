$(document).ready ->
	$('#accept_terms').on('ifChecked', ->
		$('input[type=submit]').attr('disabled', false)
		$('.inactive_submit_box').popover('disable')
		$('.inactive_submit_box').css('z-index', -1)
	)

	$('#accept_terms').on('ifUnchecked', ->
		$('input[type=submit]').attr('disabled', true)
		$('.inactive_submit_box').popover('enable')
		$('.inactive_submit_box').css('z-index', 10)
	)

	show_popover()

(exports ? this).show_popover = ->
	$('.inactive_submit_box').popover({
		html: true,
		trigger: 'hover',
		content: $('#terms_explanation').html()
	})
