Spree.ready ($) ->

  Spree.addImageHandlers = ->
    thumbnails = ($ '#product-images ul.thumbnails')
    ($ '#main-image').data 'selectedThumb', ($ '#main-image img').attr('src')
    thumbnails.find('li').eq(0).addClass 'selected'

    thumbnails.find('a').on 'click', (event) ->
      ($ '#main-image img').attr 'src', ($ event.currentTarget).attr('href')
      ($ '#main-image').data 'selectedThumb', ($ event.currentTarget).attr('href')
      ($ '#main-image').data 'selectedThumbId', ($ event.currentTarget).parent().attr('id')
      thumbnails.find('li').removeClass 'selected'
      ($ event.currentTarget).parent('li').addClass 'selected'
      false

  Spree.showVariantImages = (variantId) ->
    ($ 'li.vtmb').hide()
    ($ 'li.tmb-' + variantId).show()
    currentThumb = ($ '#' + ($ '#main-image').data('selectedThumbId'))
    if not currentThumb.hasClass('vtmb-' + variantId)
      thumb = ($ ($ '#product-images ul.thumbnails li:visible.vtmb').eq(0))
      thumb = ($ ($ '#product-images ul.thumbnails li:visible').eq(0)) unless thumb.length > 0
      newImg = thumb.find('a').attr('href')
      ($ '#product-images ul.thumbnails li').removeClass 'selected'
      thumb.addClass 'selected'
      ($ '#main-image img').attr 'src', newImg
      ($ '#main-image').data 'selectedThumb', newImg
      ($ '#main-image').data 'selectedThumbId', thumb.attr('id')

  Spree.updateVariantPrice = (variant) ->
    variantPrice = variant.data('price')
    ($ '.price.selling').text(variantPrice) if variantPrice

  Spree.disableCartForm = (variant) ->
    inStock = variant.data('in-stock')
    $('#add-to-cart-button').attr('disabled', !inStock)


  colour_select = ($ '#inside-product-cart-form select.colour')

  if colour_select.length > 0
    selected_colour = ($ '#inside-product-cart-form select.colour option:selected').text()
    console.log(selected_colour)

    colour_select.on 'change', (event) ->
      console.log('changed colour')
      false

  radios = ($ '#product-variants input[type="radio"]')

  if radios.length > 0
    selectedRadio = ($ '#product-variants input[type="radio"][checked="checked"]')
    Spree.showVariantImages selectedRadio.attr('value')
    Spree.updateVariantPrice selectedRadio
    Spree.disableCartForm selectedRadio

    radios.click (event) ->
      Spree.showVariantImages @value
      Spree.updateVariantPrice ($ this)
      Spree.disableCartForm ($ this)

  Spree.addImageHandlers()
