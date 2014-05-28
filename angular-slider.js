(function() {
  var slider;

  slider = angular.module('ngSlider', ['ngTouch']);

  slider.directive('slider', function() {
    return {
      restrict: 'A',
      scope: true,
      controller: function($scope, $element, $window, $timeout, $attrs, $q) {
        var arraysAreEqual;
        $scope.slides = $scope.activeSlides = [];
        $scope.leftPosition = $scope.currentIndex = $scope.totalWidth = 0;
        $scope.$slider = $element;
        $scope.isResizing = false;
        if ($attrs.ngShow) {
          $scope.$watch($attrs.ngShow, function() {
            return $scope.setActiveSlides(true);
          });
        }
        $scope.addSlide = function(slide, element) {
          slide.$element = element;
          $scope.slides.push(slide);
          if ($scope.defaultWidth === false) {
            $scope.$watch(function() {
              return slide.$element.is(':visible');
            }, function() {
              return $scope.setActiveSlides();
            });
            return $scope.$watch(function() {
              return slide.$element.outerWidth(true);
            }, function() {
              return $scope.isResizing = true;
            });
          } else {
            return $scope.setActiveSlides();
          }
        };
        arraysAreEqual = function(a, b) {
          var el, i, _i, _len;
          if (a === b) {
            return true;
          }
          if (!a || !b) {
            return false;
          }
          if (a.length !== b.length) {
            return false;
          }
          for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
            el = a[i];
            if (el !== b[i]) {
              return false;
            }
          }
          return true;
        };
        $scope.setActiveSlides = function(recalcWidth) {
          var activeSlides, slide, _i, _len, _ref, _ref1;
          activeSlides = [];
          _ref = $scope.slides;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            slide = _ref[_i];
            if ($scope.defaultWidth && !$scope.$viewport.is(':visible')) {
              activeSlides.push(slide);
            } else if (slide.$element.is(':visible')) {
              activeSlides.push(slide);
            }
          }
          if (!arraysAreEqual(activeSlides, (_ref1 = $scope.activeSlides) != null ? _ref1 : [])) {
            $scope.activeSlides = activeSlides;
          }
          if (recalcWidth === true) {
            return $scope.$apply(function() {
              return $scope.activeSlides = activeSlides;
            });
          }
        };
        $scope.$watch('activeSlides', function(oldSlides, newSlides) {
          var slide, totalWidth, _i, _len, _ref;
          totalWidth = 0;
          _ref = $scope.activeSlides;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            slide = _ref[_i];
            totalWidth += slide.$element.outerWidth(true);
          }
          if (!arraysAreEqual(oldSlides, newSlides)) {
            $scope.leftPosition = $scope.currentIndex = 0;
          }
          return $scope.totalWidth = Math.ceil(totalWidth / 10) * 10;
        });
        $scope.$watch('slides.length', function() {
          return $scope.setActiveSlides();
        });
        angular.element($window).bind('resize orientationchange', _.debounce(function() {
          $scope.setActiveSlides(true);
          $scope.goToSlide($scope.getCurrentSlide());
          return $scope.setButtonsActivity();
        }, 500));
        $scope.getCurrentSlide = function() {
          return $scope.activeSlides[$scope.currentIndex];
        };
        $scope.goToSlide = function(manualSlide) {
          var deferred;
          deferred = $q.defer();
          setTimeout(function() {
            var isSlide, leftPosition, slide, slideIndex, totalInView, totalLeft, _i, _j, _len, _len1, _ref, _ref1, _ref2;
            leftPosition = 0;
            _ref = $scope.countInViewPort(), totalInView = _ref[0], totalLeft = _ref[1];
            slideIndex = _.indexOf($scope.activeSlides, manualSlide);
            isSlide = $scope.activeSlides[slideIndex + totalInView];
            if (!angular.isUndefined(isSlide) && $scope.currentIndex !== 0) {
              _ref1 = $scope.activeSlides;
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                slide = _ref1[_i];
                if (slide === $scope.activeSlides[$scope.activeSlides.length - 1]) {
                  leftPosition += totalLeft;
                } else if (slide === manualSlide) {
                  break;
                } else {
                  leftPosition += slide.$element.outerWidth(true);
                }
              }
            } else if (slideIndex === 0) {
              leftPosition = 0;
            } else {
              _ref2 = $scope.activeSlides.slice(0, +(slideIndex - 1) + 1 || 9e9);
              for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
                slide = _ref2[_j];
                leftPosition += slide.$element.outerWidth(true);
              }
            }
            $scope.currentIndex = slideIndex;
            $scope.leftPosition = -leftPosition;
            return deferred.resolve(manualSlide);
          });
          return deferred.promise;
        };
        $scope.nextSlide = function() {
          var deferred;
          deferred = $q.defer();
          setTimeout(function() {
            var slide, totalInView, totalLeft, _ref;
            slide = $scope.activeSlides[$scope.currentIndex + 1];
            if ($scope.slideMultiple) {
              _ref = $scope.countInViewPort(), totalInView = _ref[0], totalLeft = _ref[1];
              slide = $scope.activeSlides[$scope.currentIndex + totalInView];
              if (slide) {
                $scope.currentIndex += 1;
                if (slide === $scope.activeSlides[$scope.activeSlides.length - 1]) {
                  $scope.leftPosition -= totalLeft;
                } else {
                  $scope.leftPosition -= slide.$element.outerWidth(true);
                }
                return deferred.resolve(slide);
              }
            } else if (slide) {
              $scope.leftPosition -= slide.$element.outerWidth(true);
              $scope.currentIndex += 1;
              return deferred.resolve(slide);
            } else {
              return deferred.reject(slide);
            }
          }, 10);
          return deferred.promise;
        };
        $scope.countInViewPort = function() {
          var canGetIntoView, canGetIntoViewMinusPadding, currentPosition, offSetBy, outOfViewportSlide, slide, _i, _len, _ref;
          canGetIntoView = 0;
          currentPosition = 0;
          _ref = $scope.activeSlides.slice($scope.currentIndex, +($scope.activeSlides.length - 1) + 1 || 9e9);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            slide = _ref[_i];
            canGetIntoView += slide.$element.outerWidth(true);
            if (canGetIntoView > $scope.$viewport.width()) {
              canGetIntoView -= slide.$element.outerWidth(true);
              canGetIntoViewMinusPadding = slide.$element.width();
              if ((canGetIntoViewMinusPadding + canGetIntoView) <= $scope.$viewport.width()) {
                canGetIntoView += slide.$element.outerWidth(true);
              } else {
                break;
              }
            }
            currentPosition += 1;
          }
          outOfViewportSlide = $scope.activeSlides[currentPosition];
          if (angular.isUndefined(outOfViewportSlide)) {
            offSetBy = 0;
          } else {
            offSetBy = (canGetIntoView + outOfViewportSlide.$element.outerWidth(true)) - $scope.$viewport.width();
          }
          return [currentPosition, offSetBy];
        };
        $scope.setButtonsActivity = function() {
          var currentSlide, totalInView, totalLeft, _ref;
          currentSlide = $scope.getCurrentSlide();
          $scope.isFirstSlide = (currentSlide === $scope.activeSlides[0] ? true : false);
          if (!$scope.slideMultiple) {
            return $scope.isLastSlide = (currentSlide === $scope.activeSlides[$scope.activeSlides.length - 1] ? true : false);
          } else {
            _ref = $scope.countInViewPort(), totalInView = _ref[0], totalLeft = _ref[1];
            if (totalInView >= $scope.activeSlides.length) {
              return $scope.isLastSlide = true;
            } else if (!$scope.activeSlides[$scope.currentIndex + Math.ceil(totalInView)]) {
              return $scope.isLastSlide = true;
            } else if (totalLeft <= 0) {
              return $scope.isLastSlide = true;
            } else if (totalLeft >= 0) {
              return $scope.isLastSlide = false;
            }
          }
        };
        $scope.$watch('activeSlides + currentIndex', function(oldSlides, newSlides) {
          return $scope.setButtonsActivity();
        });
        return $scope.prevSlide = function($event) {
          var deferred;
          deferred = $q.defer();
          setTimeout(function() {
            var slide;
            slide = $scope.activeSlides[$scope.currentIndex - 1];
            if (slide) {
              $scope.leftPosition += slide.$element.outerWidth(true);
              $scope.currentIndex -= 1;
              if (slide === $scope.activeSlides[0] && $scope.leftPosition !== 0) {
                $scope.leftPosition = 0;
              }
              return deferred.resolve(slide);
            }
          }, 10);
          return deferred.promise;
        };
      }
    };
  });

  slider.directive('sliderViewport', function() {
    return {
      restrict: 'E',
      require: '^slider',
      transclude: true,
      replace: true,
      template: "<div class='angular-slider-viewport'>\n  <ul data-ng-swipe-left='nextSlide($event);stopScroll=true'\n      data-ng-swipe-right='prevSlide($event);stopScroll=true'\n      data-ng-style='{\"left\": leftPosition + \"px\", \"position\": \"relative\", \"width\": totalWidth + \"px\"}'\n      data-ng-transclude>\n  </ul>\n</div>",
      controller: function($scope, $element, $attrs, $interval) {
        var _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
        $scope.$viewport = $element;
        $scope.slideMultiple = (_ref = $scope.$eval($attrs.slideMultiple)) != null ? _ref : false;
        $scope.autoScroll = (_ref1 = $scope.$eval($attrs.autoScroll)) != null ? _ref1 : false;
        $scope.defaultWidth = (_ref2 = $attrs.defaultWidth) != null ? _ref2 : false;
        $scope.widthOfWindow = (_ref3 = $attrs.widthOfWindow) != null ? _ref3 : false;
        $scope.autoScrollSpeed = (_ref4 = $attrs.autoScrollSpeed) != null ? _ref4 : 5000;
        if ($scope.autoScroll) {
          $scope.autoScrollSpeed = $attrs.autoScrollSpeed;
          return $interval(function() {
            if (!$scope.stopScroll) {
              return $scope.nextSlide();
            }
          }, (_ref5 = $scope.autoScrollSpeed) != null ? _ref5 : 5000);
        }
      }
    };
  });

  slider.directive('slide', function() {
    return {
      restrict: 'A',
      scope: true,
      controller: function($scope, $element, $attrs, $window, $document, $log) {
        $scope.isResponsive = false;
        $scope.responsiveWidth = {};
        $scope.isCurrentSlide = false;
        $scope.addSlide($scope, $element);
        $scope.isActive = function() {
          return $element.is(':visbile');
        };
        $scope.getResponsiveWidth = function() {
          var hasDefault, responsiveWidth, _topWidth;
          _topWidth = 0;
          angular.forEach($scope.responsiveWidth, function(slideInPercent, width) {
            var intWidth;
            intWidth = parseInt(width);
            if (angular.element($window).width() <= intWidth) {
              return _topWidth = intWidth + 'px';
            }
          });
          if (_topWidth === 0) {
            hasDefault = $scope.responsiveWidth['default'];
            if (angular.isDefined(hasDefault)) {
              _topWidth = 'default';
            } else {
              angular.forEach($scope.responsiveWidth, function(slideInPercent, width) {
                var intWidth;
                intWidth = parseInt(width);
                if (intWidth >= parseInt(_topWidth)) {
                  return _topWidth = intWidth + 'px';
                }
              });
            }
          }
          responsiveWidth = parseInt($scope.responsiveWidth[_topWidth]);
          return parseInt($scope.$slider.outerWidth(true)) * (responsiveWidth / 100.00);
        };
        $scope.getWidth = function() {
          var elementCssWidth;
          if ($scope.widthOfWindow) {
            return $($window).width();
          }
          if ($scope.defaultWidth) {
            return parseInt($scope.defaultWidth);
          }
          if ($scope.slideMultiple && !$scope.isResponsive) {
            elementCssWidth = $element.outerWidth(true);
            return parseInt(elementCssWidth);
          }
          if ($scope.slideMultiple && $scope.isResponsive) {
            return Math.round($scope.getResponsiveWidth());
          }
          return Math.round($scope.$viewport.width());
        };
        $element.width($scope.getWidth());
        $element.css({
          display: $element.css('display') !== 'none' ? 'block' : 'none',
          float: 'left'
        });
        angular.element($window).bind('orientationchange resize', function() {
          if (!$scope.isResponsive) {
            return $element.width($scope.getWidth());
          } else {
            return $element.width(Math.round($scope.getResponsiveWidth()));
          }
        });
        return angular.forEach($attrs, function(value, key) {
          var slideInPercent, width;
          if (key.indexOf('maxWidth') === 0) {
            $scope.isResponsive = true;
            width = key.split('maxWidth')[1].toLowerCase();
            slideInPercent = value;
            return $scope.responsiveWidth[width] = value;
          }
        });
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=angular-slider.js.map
*/
