window.ChatWindow =
  onLoadMore: ->

  onScroll: ->
    if @el.scrollTop < 100
      @onLoadMore()

  handleResize: ->

  initialize: ->
    @el = document.getElementById "messages"
    if @el
      @el.scrollTop = @el.scrollHeight
      @onScroll = @onScroll.bind(this)
      $("#messages").off("scroll", @onScroll).on("scroll", @onScroll)
      @shouldScrollBottom = (@el.scrollTop + @el.offsetHeight) == @el.scrollHeight

  update: ->
    @el.scrollTop = @el.scrollHeight

  componentDidUpdate: ->
    if @shouldScrollBottom
      @el.scrollTop = @el.scrollHeight
