$.rails.allowAction = (element) ->
  message = element.data('confirm')
  message_body = element.data('message_body')
  cancel_text = element.data('cancel_text')
  confirmed_text = element.data('confirmed_text')

  return true unless message

  $link = element.clone()
    .removeAttr('class')
    .removeAttr('data-confirm')
    .addClass('btn').addClass('btn-danger')
    .html(confirmed_text)

  modal_html = """
               <div class="modal" id="#{element.id}_modal">
                 <div class="modal-header">
                   <a class="close" data-dismiss="modal">×</a>
                   <h3>#{message}</h3>
                 </div>
                 <div class="modal-body">
                   <p>#{message_body}</p>
                 </div>
                 <div class="modal-footer">
                   <a data-dismiss="modal" class="btn">#{cancel_text}</a>
                 </div>
               </div>
               """
  $modal_html = $(modal_html)
  $modal_html.find('.modal-footer').append($link)
  $modal_html.modal()

  return false
  