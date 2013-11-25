slider = angular.module('ngSlider', ['ngTouch'])

slider.directive 'slider', ->
    restrict: 'A'
    scope: true
    controller: ($scope, $element, $window, $interval) ->
      $scope.slides = []
      $scope.leftPosition = $scope.currentIndex = $scope.totalWidth= 0
      $scope.isLastSlide = false
      $scope.isFirstSlide = true

      $scope.$slider = $element

      $scope.addSlide = (slide, element) ->
        slide.$element = element
        $scope.slides.push slide

        $scope.$watch ->
          return slide.$element.is(':visible')
        ,
          ->
           $scope.activeSlides = $scope.getActiveSlides()

      $scope.$watch 'slides.length', ->
        $scope.activeSlides = $scope.getActiveSlides()

      $scope.getActiveSlides = ->

        activeSlides = (slide for slide in $scope.slides when slide.$element.is(":visible"))

        if _activeSlides? == activeSlides
          return activeSlides
        else
          _activeSlides = activeSlides
          $scope.currentIndex = 0
          $scope.leftPosition = 0
          return _activeSlides

      $scope.$watch 'slides.length', ->

        for slide in $scope.slides
          $scope.totalWidth += slide.getWidth()

      angular.element($window).bind 'orientationchange resize', ->
        $scope.totalWidth = 0

        for slide in $scope.slides
          $scope.totalWidth += slide.$element.outerWidth(true)

        currentSlide = $scope.getCurrentSlide()
        leftPosition = 0

        for slide in $scope.slides

          if slide == currentSlide
            break

          leftPosition += slide.$element.outerWidth(true)

        $scope.leftPosition = -(leftPosition)

        $scope.$digest() # Apply digest so we can recalc the width

      $scope.getCurrentSlide = ->
        return $scope.slides[$scope.currentIndex]

      $scope.goToSlide= (manualSlide) ->

        leftPosition = 0
        index = 0

        for slide in $scope.slides

          if slide == manualSlide
            break

          index += 1
          leftPosition += slide.$element.outerWidth(true)

        $scope.leftPosition = -(leftPosition)
        $scope.currentIndex = index

      $scope.nextSlide = ($event) ->
        slide = $scope.activeSlides[$scope.currentIndex + 1]

        if $scope.$viewport.slideMultiple

          totalInView = ($scope.$viewport.width() / slide.$element.outerWidth(true))
          totalLeft = Math.round(totalInView) - totalInView

          slide = $scope.activeSlides[$scope.currentIndex + Math.round(totalInView)]

          if not slide and not $scope.isLastSlide
            slide = $scope.activeSlides[$scope.activeSlides.length - 1]

            if (totalLeft * 100) > 10
              $scope.offsetLeft = (slide.$element.outerWidth(true) * (totalLeft))
              $scope.leftPosition -= $scope.offsetLeft
              $scope.isLastSlide = true

            slide = null

        if slide
          $scope.leftPosition -= slide.$element.outerWidth(true)
          $scope.currentIndex += 1

      $scope.$watch 'currentIndex', ->
        currentSlide = $scope.getCurrentSlide()

        $scope.isLastSlide = (if currentSlide == $scope.activeSlides[$scope.activeSlides.length - 1] then true else false)
        $scope.isFirstSlide = (if currentSlide == $scope.activeSlides[0] then true else false)

      $scope.prevSlide = ($event) ->
        slide = $scope.activeSlides[$scope.currentIndex - 1]

        if $scope.isLastSlide and not angular.isUndefined($scope.offsetLeft)
          $scope.leftPosition += $scope.offsetLeft
          $scope.offsetLeft = null # set back to null

          $scope.isLastSlide = false

        if slide
          $scope.leftPosition += slide.$element.outerWidth(true)
          $scope.currentIndex -= 1

slider.directive 'sliderViewport', ->
  restrict: 'E'
  require: '^slider'
  transclude: true
  replace: true
  template:
    "
    <div class='angular-slider-viewport'>
      <ul data-ng-swipe-left='nextSlide($event);stopScroll=true'
          data-ng-swipe-right='prevSlide($event);stopScroll=true'
          style='left: {{leftPosition}}px; position: relative; width: {{totalWidth}}px;'
          data-ng-transclude>
      </ul>
    </div>
    "
  controller: ($scope, $element, $attrs, $interval) ->
    $scope.$viewport = $element

    $scope.$viewport.slideMultiple = $attrs.slideMultiple ? false
    $scope.defaultWidth = $attrs.defaultWidth ? false
    $scope.widthOfWindow = $attrs.widthOfWindow ? false
    $scope.autoScroll = $attrs.autoScroll ? false
    $scope.autoScrollSpeed = $attrs.autoScrollSpeed ? 5000

    if $scope.autoScroll

      $scope.autoScrollSpeed = $attrs.autoScrollSpeed

      $interval ->
          if not $scope.stopScroll
            $scope.nextSlide()
        ,
          $scope.autoScrollSpeed ? 5000

  link: (scope, element, attrs, prntCtrl) ->

    scope.totalWidth += parseInt(
      parseInt(element.css('margin-left')) + parseInt(element.css('margin-right'))
    ) || 0


slider.directive 'slide', ->
  restrict: 'A'
  scope: true
  controller: ($scope, $element, $attrs, $window, $document) ->

    $scope.isResponsive = false
    $scope.responsiveWidth = {}

    $scope.addSlide $scope, $element

    $scope.getResponsiveWidth = ->

      _topWidth = 0

      angular.forEach $scope.responsiveWidth, (slideInPercent, width) ->
        intWidth = parseInt(width)
        if angular.element($window).width() <= intWidth
          _topWidth = intWidth

      return (parseInt($scope.$slider.outerWidth(true))) * (parseInt($scope.responsiveWidth[_topWidth+'px']) / 100)

    $scope.getWidth = ->

      if $scope.widthOfWindow
        return $($window).width()

      if $scope.defaultWidth
        return parseInt($scope.defaultWidth)

      if $scope.$viewport.slideMultiple and not $scope.isResponsive
        elementCssWidth = $element.outerWidth(true)
        return parseInt(elementCssWidth)
      else
        return $scope.getResponsiveWidth()

      return $scope.$viewport.outerWidth(true)

    $element.width($scope.getWidth())

    $element.css
      display: 'inline-block' # Probably dont need this.
      float: 'left'

    angular.element($window).bind 'orientationchange resize', ->
      if not $scope.isResponsive
        $element.width($scope.getWidth())
      else
        $element.width($scope.getResponsiveWidth())

    angular.forEach $attrs, (value, key) ->

      if key.indexOf('maxWidth') == 0

        $scope.isResponsive = true

        width = key.split('maxWidth')[1]
        slideInPercent = value
        $scope.responsiveWidth[width] = value
