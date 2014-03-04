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

        $scope.totalWidth = Math.ceil(totalWidth / 10) * 10

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

        leftPosition = 0
        [totalInView, totalLeft] = $scope.countInViewPort()
        slideIndex = _.indexOf($scope.activeSlides, manualSlide)
        isSlide = $scope.activeSlides[slideIndex + totalInView]

        if not angular.isUndefined(isSlide) and $scope.currentIndex != 0
          for slide in $scope.activeSlides
            if slide == $scope.activeSlides[$scope.activeSlides.length - 1]
              leftPosition += totalLeft
            else if slide == manualSlide
              break
            else
              leftPosition += slide.$element.outerWidth(true)

        else if slideIndex == 0
            leftPosition = 0

        else
          for slide in $scope.activeSlides[0 .. slideIndex - 1]
              leftPosition += slide.$element.outerWidth(true)

        $scope.currentIndex = slideIndex
        $scope.leftPosition = -(leftPosition)

      $scope.nextSlide = () ->
        slide = $scope.activeSlides[$scope.currentIndex + 1]

        if $scope.slideMultiple

          [totalInView, totalLeft] = $scope.countInViewPort()
          slide = $scope.activeSlides[$scope.currentIndex + totalInView]

          if slide
            $scope.currentIndex += 1

            if slide == $scope.activeSlides[$scope.activeSlides.length - 1]
              $scope.leftPosition -= totalLeft
            else
              $scope.leftPosition -= slide.$element.outerWidth(true)

        else if slide
          $scope.leftPosition -= slide.$element.outerWidth(true)
          $scope.currentIndex += 1

      $scope.countInViewPort = ->

        canGetIntoView = 0
        currentPosition = 0

        for slide in $scope.activeSlides[$scope.currentIndex .. $scope.activeSlides.length - 1]
          canGetIntoView += slide.$element.outerWidth(true)
          if canGetIntoView > $scope.$viewport.width()

            canGetIntoView -= slide.$element.outerWidth(true) # Remove since this is out of viewport
            canGetIntoViewMinusPadding = slide.$element.width() # See if we can still get in with just padding removed.

            if (canGetIntoViewMinusPadding + canGetIntoView) <= $scope.$viewport.width()
              canGetIntoView += slide.$element.outerWidth(true)
            else
              break

          currentPosition += 1

        outOfViewportSlide = $scope.activeSlides[currentPosition]

        if angular.isUndefined(outOfViewportSlide)
          offSetBy = 0
        else
          offSetBy = (canGetIntoView + outOfViewportSlide.$element.outerWidth(true)) - $scope.$viewport.width()

        return [currentPosition, offSetBy]

      $scope.setButtonsActivity = ->
        currentSlide = $scope.getCurrentSlide()

        $scope.isFirstSlide = (if currentSlide is $scope.activeSlides[0] then true else false)

        if not $scope.slideMultiple
          $scope.isLastSlide = (if currentSlide is $scope.activeSlides[$scope.activeSlides.length - 1] then true else false)
        else
          [totalInView, totalLeft] = $scope.countInViewPort()
          if totalInView >= $scope.activeSlides.length
            $scope.isLastSlide = true
          else if not $scope.activeSlides[$scope.currentIndex + Math.ceil(totalInView)]
            $scope.isLastSlide = true
          else if totalLeft <= 0
            $scope.isLastSlide = true
          else if totalLeft >= 0
            $scope.isLastSlide = false

      $scope.$watch 'activeSlides + currentIndex', (oldSlides, newSlides) ->
        $scope.setButtonsActivity()

      $scope.prevSlide = ($event) ->
        slide = $scope.activeSlides[$scope.currentIndex - 1]

        if slide
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

    $scope.slideMultiple = $scope.$eval($attrs.slideMultiple) ? false
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

      if $scope.slideMultiple and not $scope.isResponsive
        elementCssWidth = $element.outerWidth(true)
        return parseInt(elementCssWidth)

      if $scope.slideMultiple and $scope.isResponsive
        return Math.round($scope.getResponsiveWidth())

      return Math.round($scope.$viewport.width())

    $element.width($scope.getWidth())

    $element.css
      display: if $element.css('display') != 'none' then 'block' else 'none'
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
