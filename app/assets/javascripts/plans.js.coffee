# Accordion using jQuery UI http://jqueryui.com (as are tabs - JS in plans/template partial)

jQuery ->

  $.DirtyForms.dialog = 
    selector: ''
    fire: (message, dlgTitle) ->
      e = jQuery.Event("click")        
      if confirm dlgTitle + "\n\n" + message
        $.DirtyForms.decidingContinue(e)
      else
        $.DirtyForms.decidingCancel(e)
    bind: ->
    refire: (content) ->
      return false
    stash: ->
      return false


  # With HTC for rounded corners we run out of memory...
  @ie_disable_tabs = jQuery.browser.msie && (parseInt(jQuery.browser.version) < 9)
  @ie_disable_accordion = jQuery.browser.msie && (parseInt(jQuery.browser.version) < 9)
    
  $("#rights_tabs").tabs()

  @guidance_dialogue = '' 
  
  guidance_blocks = () ->
    $(".guidance-area .dialogue").livequery ->
      $(this).dialog("destroy")
    $(".guidance-area .dialogue").livequery ->
      $(this).dialog
        autoOpen: false
        show: 'fold'
        hide: 'clip'
        # position: 'right'
        height: 300
        width: 400
        modal: false

    $("a.guidance-button").livequery "click", (event) ->
      event.preventDefault()
      event.stopPropagation()
      ref = $(this).data("guide")
      $("#dialogue-" + ref).dialog("open")
      $("#dialogue-" + ref).dialog("moveToTop")

    $(".dialogue a").livequery ->
      $(this).unbind("click").click (event) ->
        event.preventDefault()
        event.stopPropagation()
        window.open(this.href, '_blank')
      

  guidance_hovers = () ->
    $("#templates .answer li.input.radio").livequery ->
      $(this).mouseenter -> 
        open_guidance(this)
        return
      .mouseleave ->
        close_guidance()
        return

    $("#templates .answer li.input.text textarea").livequery ->
      $(this).focusin ->
        open_guidance(this)
        return
        
    $("#templates .answer li.input.text textarea").livequery ->
      $(this).focusout ->
        close_guidance()
        return

    $("#templates .answer li.input.url input").livequery ->
      $(this).focusin ->
        open_guidance(this)
        return

    $("#templates .answer li.input.url input").livequery ->
      $(this).focusout ->
        close_guidance()
        return

  open_guidance = (e) =>
    ref = $(e).parents("tr").find("td.guidance-area div.popup a.guidance-button").data("guide").toString()
    unless ref.length == 0
      dialogue = "#dialogue-" + ref
      unless $(dialogue).dialog("isOpen")
        close_guidance()
        # Nasty workaround to stop dialog stealing focus...
        $(dialogue).dialog("widget").css("visibility", "hidden");  
        $(dialogue).dialog("open")
        $(dialogue).dialog("widget").css("visibility", "visible");
        @guidance_dialogue = dialogue
      $(dialogue).dialog("moveToTop")

  close_guidance = () =>
    if @guidance_dialogue.length
      $(@guidance_dialogue).dialog("close")
      @guidance_dialogue = ''


  unless @ie_disable_accordion
    $("#templates.accordion .panel").accordion
      active: ".current",
      clearStyle: true,
      autoHeight: false,
      event: '',
      changestart: (event, ui) =>
        ui.newHeader.next("div").html($("#templates").data('preloader'))
        href = $(ui.newHeader.find("a")).attr("href") 
        $.get href, (data) ->
          ui.newHeader.next("div").html(data)

    $('#templates.accordion .ui-accordion-header a').click ->
      i = $('#templates.accordion .ui-accordion-header a').index(this)
      
      form = $("form.phase_edition_instance")
      if form.isDirty() 
        # Submit the form via AJAX
        $.post(
          form.attr('action')
          form.serialize()
          (data, textStatus, jqXHR) ->
              # data saved
        )
        return false
      
      $("form.phase_edition_instance").cleanDirty()
      $("#templates.accordion .panel").accordion('activate', i)
      return false


  $("form.phase_edition_instance").livequery ->
    $(this).dirtyForms()
  $(".hide_opt").livequery ->
    $(this).after('<a class="hide-link" href="#">[Remove]</a>').next("a").on "click", ->
      $(this).prev().find("input[type=hidden]").val("1")
      $(this).closest("form").setDirty()
      $(this).closest("tr").slideUp()
      
  $("form.phase_edition_instance a.create_link").livequery ->
    $(this).click ->
      form = $("form.phase_edition_instance")
      if form.isDirty() 
        $.post(
          form.attr('action')
          form.serialize()
          (data, textStatus, jqXHR) ->
              # data saved
        )

        return false
      $("form.phase_edition_instance").cleanDirty()
  

  guidance_blocks()
  # guidance_hovers()

  if @ie_disable_accordion
    section_id = "#templates .sections"
  else
    section_id = "#templates.accordion .ui-accordion-content-active .sections"

  if @ie_disable_tabs
    plan_conditionals()
  else
    $(section_id).livequery ->
      $(this).tabs
        cache: false
        ajaxOptions:
          cache: false
        event: ''
        load: (event, ui) -> 
          $(section_id + " ol a").removeAttr("title")
          plan_conditionals()
          $("form.phase_edition_instance").cleanDirty()
        spinner: $("#templates").data('preloader')
  
    $(section_id + ' .ui-tabs-nav a').livequery "click", (event) ->
      event.stopImmediatePropagation()

      form = $("form.phase_edition_instance")
      if form.isDirty() 
        # Submit the form via AJAX
        $.post(
          form.attr('action')
          form.serialize()
          (data, textStatus, jqXHR) ->
              # data saved
        )

      $("form.phase_edition_instance").cleanDirty()
      i = $(section_id + ' .ui-tabs-nav a').index(this)
      $(section_id).tabs('select', i)

      return false


  # Hide the position field and boilerplate text.  Done here so degrades if JS not running
  $('head').append '<style>div.hide_opt { display: none; }</style>'
