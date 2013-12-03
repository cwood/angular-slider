Angular Slider
=============================

[![Build Status](https://magnum.travis-ci.com/hzdg/angular-slider.png?token=JSaJz6K8fcgAdvJmtR9u&branch=master)](https://magnum.travis-ci.com/hzdg/angular-slider)

A generic slider for single and multi items in a viewport.
Also responsive.

Directives
----------------------------

Three basic directives:

* ``slider``
   * Overall controller of the slider. Most of the calculations are done here
   * This is a attribute used on a element

* ``slider-viewport``
   * Options and other confugration are set on this element
   * This is a html element. This also allows transclusion. So you can use
     ng-repeat to get slides from backend.

* ``slide``
   * Model used for calculation width, and setting a responsive width.
   * This is a attribute on a element.

Api
----------------------------

The slider has a couple functions that can be used on ng-click, or any other angular event.
They are ``nextSlide()`` and ``prevSlide()`` along with ``goToSlide(slide)``.

Accessing your slides
-----------------------
To access your slides you can access them through the main scope as ``activeSlides`` what
constitues a active slide is being visable, or having a default width and not being visable.

For example if you want to use the default angular filtering, with ng-show, ng-hide with values you can use this to filter out objects in your activeSlides.


Creating your own slide
-----------------------

You also dont need to use the default slide directive. You can create your own if you want
to add more controller logic or add new functions. This can also be accomplished through adding a new directive and using the same scope. Each slide directive creates a new child scope that is added to the parent scope through the ``addSlide($scope, $element)`` method. If you want to tottally override this. You need to create a method called ``getWidth`` that will return back a integer value.


Running tests
-------------------------

To run the tests just run ``grunt test`` this will run the tests through karma/jasmin. Also tests will run on new pushes to master through travis.
