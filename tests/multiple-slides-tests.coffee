describe "multiple slides", ->

  slider = $scope = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport default-width="150px" slide-multiple='true' style='overflow: hidden: width: 50%; margin: 0 auto;'>
            <li slide>
              <h1>Slide A</h1>
            </li>
            <li slide>
              <h1>Slide B</h1>
            </li>
            <li slide>
              <h1>Slide C</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $(slider).appendTo('body')
    slider.scope().$apply()

    $scope = slider.scope()

  it "should toggle on slides multiple boolean", ->
    expect($scope.$viewport.slideMultiple).toBe true
