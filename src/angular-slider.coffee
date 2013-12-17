slider = angular.module('ngSlider', ['ngTouch'])

slider.directive 'slider', ->
    restrict: 'A'
    scope: true
    controller: ($scope, $element, $window, $timeout) ->
      $scope.slides = $scope.activeSlides = []
      $scope.leftPosition = $scope.currentIndex = $scope.totalWidth= 0
      $scope.$slider = $element
      $scope.isResizing = false

      $scope.addSlide = (slide, element) ->
        slide.$element = element
        $scope.slides.push slide

        if $scope.defaultWidth == false
          $scope.$watch ->
              return slide.$element.is(':visible')
          ,
            ->
             $scope.setActiveSlides()

          $scope.$watch ->
            return slide.$element.outerWidth(true)
          ,
            ->
              $scope.isResizing = true
        else
          $scope.setActiveSlides()

      arraysAreEqual = (a, b) ->
        return true if a is b
        return false if not a or not b
        return false if a.length isnt b.length
        for el, i in a
          return false if el isnt b[i]
        true

      $scope.setActiveSlides = (recalcWidth) ->

        activeSlides = []

        for slide in $scope.slides
          if $scope.defaultWidth and not $scope.$viewport.is(':visible')
            activeSlides.push slide
          else if slide.$element.is(':visible')
            activeSlides.push slide

        if not arraysAreEqual activeSlides, $scope.activeSlides ? []
          $scope.activeSlides = activeSlides

        if recalcWidth is true
          $scope.activeSlides = activeSlides
          $scope.$apply()

      $scope.$watch 'activeSlides', (oldSlides, newSlides) ->

        totalWidth = 0

        for slide in $scope.activeSlides
            totalWidth += slide.$element.outerWidth(true)

        if not arraysAreEqual oldSlides, newSlides
          $scope.leftPosition = $scope.currentIndex = 0

        $scope.totalWidth = totalWidth

      $scope.$watch 'slides.length', ->
        $scope.setActiveSlides()

      angular.element($window).bind 'resize orientationchange', _.debounce( ->
        $scope.setActiveSlides(true)
        $scope.goToSlide($scope.getCurrentSlide()) # Go to the users current slide
        $scope.setButtonsActivity() # Set the buttons after resize.
      , 500)

      $scope.getCurrentSlide = ->
        return $scope.activeSlides[$scope.currentIndex]

      $scope.goToSlide= (manualSlide) ->

        leftPosition = index = 0

        for slide in $scope.activeSlides

          if slide is manualSlide
            break

          index += 1
          leftPosition += slide.$element.outerWidth(true)

        $scope.leftPosition = -(leftPosition)
        $scope.currentIndex = index

      $scope.nextSlide = () ->
        slide = $scope.activeSlides[$scope.currentIndex + 1]

        if $scope.$viewport.slideMultiple

          [totalInView, totalLeft] = $scope.countInViewPort(slide)
          slide = $scope.activeSlides[$scope.currentIndex + Math.ceil(totalInView)]

          if not slide and not $scope.offsetLeft
            slide = $scope.activeSlides[$scope.activeSlides.length - 1]

            if (totalLeft * 100) > 1 # Has to be greater than a percentage
              $scope.offsetLeft = (slide.$element.outerWidth(true) * (totalLeft))
              $scope.currentIndex += 1
              $scope.leftPosition -= $scope.offsetLeft

            slide = null

        if slide
          $scope.leftPosition -= slide.$element.outerWidth(true)
          $scope.currentIndex += 1

      $scope.countInViewPort = (slide) ->
        totalInView = ($scope.$viewport.width() / slide.$element.outerWidth(true))
        totalLeft = Math.ceil(totalInView) - totalInView # Always round up
        return [totalInView, totalLeft]

      $scope.setButtonsActivity = ->
        currentSlide = $scope.getCurrentSlide()

        $scope.isFirstSlide = (if currentSlide is $scope.activeSlides[0] then true else false)

        if not $scope.$viewport.slideMultiple
          $scope.isLastSlide = (if currentSlide is $scope.activeSlides[$scope.activeSlides.length - 1] then true else false)
        else
          [totalInView, totalLeft] = $scope.countInViewPort(currentSlide)
          if totalInView >= $scope.activeSlides.length
            $scope.isLastSlide = true
          else if totalLeft >= 0.0 and not $scope.offsetLeft
            $scope.isLastSlide = false
          else if not $scope.activeSlides[$scope.currentIndex + Math.ceil(totalInView)]
            $scope.isLastSlide = true
          else
            $scope.isLastSlide = false

      $scope.$watch 'activeSlides + currentIndex', (oldSlides, newSlides) ->
        $scope.setButtonsActivity()

      $scope.prevSlide = ($event) ->
        slide = $scope.activeSlides[$scope.currentIndex - 1]

        if $scope.offsetLeft
          $scope.leftPosition += $scope.offsetLeft
          $scope.offsetLeft = null # set back to null
          $scope.currentIndex -= 1
        else if slide
          $scope.leftPosition += slide.$element.outerWidth(true)
          $scope.currentIndex -= 1
          if slide is $scope.activeSlides[0] and $scope.leftPosition != 0
            $scope.leftPosition = 0

slider.directive 'sliderViewport', ->
  restrict: 'E'
  require: '^slider'
  transclude: true
  replace: true
  template:
    """
    <div class='angular-slider-viewport'>
      <ul data-ng-swipe-left='nextSlide($event);stopScroll=true'
          data-ng-swipe-right='prevSlide($event);stopScroll=true'
          data-ng-style='{"left": leftPosition + "px", "position": "relative", "width": totalWidth + "px"}'
          data-ng-transclude>
      </ul>
    </div>
    """
  controller: ($scope, $element, $attrs, $interval) ->
    $scope.$viewport = $element

    $scope.$viewport.slideMultiple = $scope.$eval($attrs.slideMultiple) ? false
    $scope.autoScroll = $scope.$eval($attrs.autoScroll) ? false

    $scope.defaultWidth = $attrs.defaultWidth ? false
    $scope.widthOfWindow = $attrs.widthOfWindow ? false
    $scope.autoScrollSpeed = $attrs.autoScrollSpeed ? 5000

    if $scope.autoScroll

      $scope.autoScrollSpeed = $attrs.autoScrollSpeed

      $interval ->
          if not $scope.stopScroll
            $scope.nextSlide()
        ,
          $scope.autoScrollSpeed ? 5000

slider.directive 'slide', ->
  restrict: 'A'
  scope: true
  controller: ($scope, $element, $attrs, $window, $document, $log) ->

    $scope.isResponsive = false
    $scope.responsiveWidth = {}

    $scope.addSlide $scope, $element

    $scope.isActive = ->
      return $element.is(':visbile')

    $scope.getResponsiveWidth = ->

      # First we go down in sizes tell we find one that matches
      # if we dont find one then we keep going up until we get the
      # biggest size we can.

      _topWidth = 0

      angular.forEach $scope.responsiveWidth, (slideInPercent, width) ->
        intWidth = parseInt(width)

        if angular.element($window).width() <= intWidth
          _topWidth = intWidth + 'px'

      if _topWidth == 0
        hasDefault = $scope.responsiveWidth['default']
        if angular.isDefined(hasDefault)
          _topWidth = 'default'
        else
          # get the highest max-width and use that
          angular.forEach $scope.responsiveWidth, (slideInPercent, width) ->
            intWidth = parseInt(width)
            if intWidth >= parseInt(_topWidth)
              _topWidth = intWidth + 'px'

      responsiveWidth = parseInt($scope.responsiveWidth[_topWidth])
      return parseInt($scope.$slider.outerWidth(true)) * ((responsiveWidth) / 100.00)

    $scope.getWidth = ->

      if $scope.widthOfWindow
        return $($window).width()

      if $scope.defaultWidth
        return parseInt($scope.defaultWidth)

      if $scope.$viewport.slideMultiple and not $scope.isResponsive
        elementCssWidth = $element.outerWidth(true)
        return parseInt(elementCssWidth)

      if $scope.$viewport.slideMultiple and $scope.isResponsive
        return $scope.getResponsiveWidth()

      return $scope.$viewport.outerWidth(true)

    $element.width(Math.round($scope.getWidth()))

    $element.css
      display: if $element.css('display') != 'none' then 'inline-block' else 'none'
      float: 'left'

    angular.element($window).bind 'orientationchange resize', ->
      if not $scope.isResponsive
        $element.width($scope.getWidth())
      else
        $element.width(Math.round($scope.getResponsiveWidth()))

    angular.forEach $attrs, (value, key) ->

      if key.indexOf('maxWidth') == 0

        $scope.isResponsive = true

        width = key.split('maxWidth')[1].toLowerCase() # if this is a string lower it
        slideInPercent = value
        $scope.responsiveWidth[width] = value
