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

### Scene Graph design considerations

So, i want to design the scene graph so that it's declarative 
- and maximizes flexibility, both at design time and at runtime.

design questions:
- what is the difference between MeshNodes and SceneGraphNodes?
- should the material/texture be separate from the meshes?
- how to best use dependency injection for the scene graphs?
- how does this all tie into renderers, resource utilization and render pipeline assembly?
- how can meshes be composable? how can meshes and materials be composed?

design constraints:
- want to easily run geometry shaders on scene graph and pre loaded meshs
- don't care about memory constraints
  - just copy data from the mesh graph to the scene graph
  - then load data into buffers from the scene graph
    - try to manipulate vertex data while retaining it in buffers after this point
    - shit, this would mean handling data loading for the mesh graph and scene graph differently anyways
- need a resource manager
  - the only resource i care about optimizing at this point are textures with a texture atlas
  - don't really care about buffer utilization or how memory is slabbed out in buffers for objects
    - way too complex
- a mesh graph should just be another instance of a scene graph
  - so, i need to be able to easily port objects between scene graphs

Split Mesh Graph and Scene Graph
- should the meshes be loaded into a separate mesh graph structure first, so they can easily be reused?
- or should the meshes & mesh generation stuff be split to a separate framework?
  - this would make it easy to customize behavior for mesh generation,
  - but then it'd be difficult and slow to do this geometry manipulation during runtime
  - also, if Compute Shaders are used as Geometry Shaders, 
    - this means that a resource manager needs to be capable of working with both mesh graph & scene graph objects
    - if it is to load the data for these objects into buffers
    - this could be abstracted to a meshable protocol or something, but this route seems too complicated
- or should there simply be multiple scene graphs to contain objects being loaded?
  - the problem here is that it's more work to parse through the tree of nodes
    - whereas, with a specific mesh graph, the data structure is specialized & stripped down just for meshes
- having a Mesh Graph, or at least some other structure to work with just mesh data, 
  - makes it easier to reuse meshes and to define logical groupings for manipulations

MeshCategory (kind/protocol for MeshTypes)
- how to define mesh morphisms between types?

Scene Graph designed with animation & rendering attributes attached to nodes: [here](https://3fstudios.files.wordpress.com/2008/02/graphics05.jpg)





