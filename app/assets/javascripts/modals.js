$(function() {
  var modal_holder_selector, modal_selector;
  modal_holder_selector = '#modal-holder';
  modal_selector = '#mainModal';
  $(document).on('click', 'a[data-modal]', function() {
    var location;
    location = $(this).attr('href');
    $.get(location, function(data) {
      $(modal_holder_selector).html(data).find(modal_selector).modal('show');

      this.editor = new MediumEditor('.editable', {
        placeholder: {
          text: 'Describe your project in as much detailing as possible..',
          hideOnClick: false
        }
      });
      $('.editable').mediumInsert({
        editor: this.editor,
        addons: {
          images: {
            uploadCompleted: function($el, data) {
              var photo;
              photo = data.result.files[0];
              $("img", $el).data("delete-url", photo.delete_url);
              if (!($("#post_link_image").val().length > 0)) {
                return $("#post_link_image").val(photo.cover_url);
              }
            },
            fileUploadOptions: {
              url: "/photos"
            }
          }
        }
      });
    });
    return false;
  });
  return $(document).on('ajax:success', 'form[data-modal]', function(event, data, status, xhr) {
    var url;
    url = xhr.getResponseHeader('Location');
    if (url) {
      window.location = url;
    } else {
      $('.modal-backdrop').remove();
      $(modal_holder_selector).html(data).find(modal_selector).modal();
    }
    return false;
  });
});

