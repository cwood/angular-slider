ngSliderContrib = angular.module 'ngSliderContrib', ['ngTouch', 'ngSlider']

ngSliderContrib.directive 'sliderProgressBar', ->
  restrict: 'E',
  require: '^slider'
  transclude: false
  controller: ($scope, $element, $interval, $timeout) ->

    progressBar = $element.find('.progress-bar').first()
    oldSlide = null
    $scope.stopScroll = false

    $scope.$watch 'currentIndex', ->
      progressBar.removeClass('active')

      $timeout ->
        if not $scope.stopScroll
          progressBar.addClass('active')
      ,
        100

  template:
    """
      <div class='progress-bar-container' data-ng-class="{'stop-scrolling': stopScroll}">
        <div class='progress-bar'></div>
      </div>
    """
  replace: true


ngSliderContrib.directive 'setActiveSlide', ->

  restrict: 'A'
  controller: ($scope, $element) ->

    $scope.isActive =  (classSlug) ->
      currentSlide = $scope.getCurrentSlide()
      return currentSlide.$element.hasClass(classSlug)

    $scope.goToFirstInCategory = (classSlug, $element) ->

      $scope.stopScroll = true

      slides = (slide for slide in $scope.slides when slide.$element.hasClass(classSlug))
      $scope.goToSlide(slides[0])

      $scope.$apply()
