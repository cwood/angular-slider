describe "responsive slider", ->

  slider = $scope = $windowElm = null
  currentHeight = 600
  currentWidth = 900

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope, $window) ->

    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport default-width="150px" style='width: 100%'>
            <li slide max-width-600px='33%' max-width-360px='100%' max-width-default='25%'>
              <h1>Slide A</h1>
            </li>
            <li slide max-width-600px='33%' max-width-360px='100%' max-width-default='25%'>
              <h1>Slide B</h1>
            </li>
            <li slide max-width-600px='33%' max-width-360px='100%' max-width-default='25%'>
              <h1>Slide C</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $('body').html(slider)
    $scope = slider.scope()
    slider.scope().$apply()

  it 'should have 2 max widths', ->
    slide = $scope.getCurrentSlide()
    expect(slide.responsiveWidth).toEqual
      '600px': '33%',
      '360px': '100%'
      default: '25%'

  it 'should be responsive', ->
    slide = $scope.getCurrentSlide()
    expect(slide.isResponsive).toBe true

  it 'should adjust to current window size and it should be 25%', ->
    slide = $scope.getCurrentSlide()
    expect(slide.getResponsiveWidth()).toBe($scope.$viewport.width() * .25)


describe "responsive slider without default", ->

  slider = $scope = $window = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope, $window) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport default-width="150px">
            <li slide max-width-600px='33%' max-width-360px='100%'>
              <h1>Slide A</h1>
            </li>
            <li slide max-width-600px='33%' max-width-360px='100%'>
              <h1>Slide B</h1>
            </li>
            <li slide max-width-600px='33%' max-width-360px='100%'>
              <h1>Slide C</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $('body').html(slider)
    $scope = slider.scope()
    slider.scope().$apply()

  it 'should be 33% of the viewport at 911px', ->
    slide = $scope.getCurrentSlide()
    expect(slide.getResponsiveWidth()).toBe($scope.$viewport.width() * .33)
