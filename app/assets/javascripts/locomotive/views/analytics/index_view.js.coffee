#= require raphael/raphael.js
#= require g.raphael/g.raphael.js
#= require g.raphael/g.line.js

Locomotive.Views.Analytics ||= {}

class Locomotive.Views.Analytics.IndexView extends Backbone.View
  el: '#content'
  render: ->
    return @