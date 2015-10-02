$(document).ready ->
	$('select').not('.resettable').chosen()
	$('.resettable').chosen({ allow_single_deselect: true })
