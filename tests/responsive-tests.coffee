describe "responsive slider", ->

  slider = $scope = $window = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope, $window) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport default-width="150px">
            <li slide max-width-1600px='33%' max-width-960px='100%'>
              <h1>Slide A</h1>
            </li>
            <li slide max-width-1600px='33%' max-width-960px='100%'>
              <h1>Slide B</h1>
            </li>
            <li slide max-width-1600px='33%' max-width-960px='100%'>
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
      '1600px': '33%',
      '960px': '100%'

  it 'should be responsive', ->
    slide = $scope.getCurrentSlide()
    expect(slide.isResponsive).toBe true

  it 'should adjust to current window size and it should be 33%', ->
    slide = $scope.getCurrentSlide()
    expect(slide.getResponsiveWidth()).toBe(300.63)
