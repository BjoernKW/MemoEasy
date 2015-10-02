# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready( ->
	normalCssClass = ''

	$('.plan_wrapper').mouseenter((e) ->
		plan = $(this).children('.plan')

		if plan.hasClass('silver')
			normalCssClass = 'silver'
		if plan.hasClass('gold')
			normalCssClass = 'gold'
		if plan.hasClass('platinum')
			normalCssClass = 'platinum'

		$(this).children('.plan').removeClass(normalCssClass)
		$(this).children('.plan').addClass('featured_plan')

		$(this).children('.btn').removeClass('btn-brand')
		$(this).children('.btn').addClass('btn-brand-dark')

		unless $(this).hasClass('featured')
			$('.featured').children('.btn').removeClass('btn-brand-dark')
			$('.featured').children('.btn').addClass('btn-brand')

		$('.featured').addClass('featured_deactivated')
		$('.featured').removeClass('featured')
		$('.gold').addClass('gold_not_featured')
	)

	$('.plan_wrapper').mouseleave((e) ->
		$(this).children('.plan').removeClass('featured_plan')
		$(this).children('.plan').addClass(normalCssClass)

		$(this).children('.btn').removeClass('btn-brand-dark')
		$(this).children('.btn').addClass('btn-brand')

		$('.featured_deactivated').children('.btn').removeClass('btn-brand')
		$('.featured_deactivated').children('.btn').addClass('btn-brand-dark')

		$('.featured_deactivated').addClass('featured')
		$('.featured').removeClass('featured_deactivated')
		$('.gold').removeClass('gold_not_featured')
	)

	$('.carousel').carousel({
		interval: 5000
	})
)
