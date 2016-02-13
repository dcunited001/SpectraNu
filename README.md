Spectra
=======

[Trello Board](https://trello.com/b/FYL0pBuF/spectra) if you want to
contribute or see what i'm working on

**N.B.** -> this library will be moved to replace dcunited001/Spectra at
some point. Soooo, actually using it is not recommended yet

rewriting this library for like the fifth time, since cocoapods is broken.
- and now i'm rewriting it again to have proper dependency injection'


- [Creating a multi-platform workspace](http://www.swift-studies.com/blog/2014/6/30/creating-a-pure-swift-framework-for-both-ios-and-mac) actually not a great article.  not too bad, but i made a lot of mistakes.
- [http://www.uraimo.com/2015/09/29/Swift2.1-Function-Types-Conversion-Covariance-Contravariance/](covariance & contravariance in swift)
- [http://www.russbishop.net/swift-2-1](changes in swift 2.1)


todo for dependency injection:
- set up Swinject
  - finished setting up framework with carthage
  - need to figure out how to interface with Swinject containers via controllers
    - want to separate the render pipeline swinject containers from the scene graph swinject containers
    - lock container for render pipeline after it's initially configured.  for security and whatnot.
- rewrite metal framework XML parsers to construct a swinject container
  - replace SpectraDescriptorManager with a class that opens XML/JSON and imports data
    - configuring swinject containers along the way
    - swinject makes it much easier (i think) to have references to other nodes in XML
  - maybe add json parsers ... but probably not.
- for now, leave it at just handing metal framework objects
  - think about handling nodes, meshes, etc later on
    - swinject containers, if used for mesh generators, will need to be layered
  - just use framework to set up render pipelines and use scene graph for nodes
    - coolest part: collections of renderer functions cleverly piped together
