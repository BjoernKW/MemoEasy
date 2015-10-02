$(document).ready ->
	$('#customer_email').popover({
		html: true,
		trigger: 'hover',
		content: $('#messaging_details_explanation').html()
	})
	$('#appointment_customer_attributes_email').popover({
		html: true,
		trigger: 'hover',
		content: $('#messaging_details_explanation').html()
	})
	$('#customer_mobile_phone').popover({
		html: true,
		trigger: 'hover',
		content: $('#messaging_details_explanation').html()
	})
	$('#appointment_customer_attributes_mobile_phone').popover({
		html: true,
		trigger: 'hover',
		content: $('#messaging_details_explanation').html()
	})
