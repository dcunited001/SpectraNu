## Spectra => Metal Graphics Engine (Swift - iOS - OSX)

I'm back to building my 3D Graphics engine.  Spectra is really designed for learning low-level graphics 
techniques.  I'm building it primarily to learn these techniques myself and to explore mathematic concepts.  
But I've designed it in such a way that it is easy for users to pick up the basics of low-level 3D graphics.  

[Trello Board](https://trello.com/b/FYL0pBuF/spectra) if you want to contribute or see what i'm building next.

> **N.B.** -> this library will be moved to replace [dcunited001/Spectra](http://github.com/dcunited001/Spectra) at
> some point. Soooo, actually using it is not recommended yet. I'm rewriting this library for like the fifth 
> time (using Carthage) since cocoapods is broken.  And now i'm rewriting it again to have proper 
> dependency injection'

## Declarative | Composable | Functional

### 3D Graphics with a first-party, strongly typed functional language. 

### Everything is declarative - from render pipelines to assets and meshes. 

### Everything you need is accessible through dependency injection.  

### Everything is composable, with a focus on combinating monadic mesh/submesh generation for dynamic and flexible geometry manipulation (hopefully in real time)

### Composable, dynamically swappable, parallelizable graphics.

### Stream Data to Metal Inputs & Buffers, for audio visualization or vertex streaming.

Here's some video of [OSX audio visualization](https://www.youtube.com/watch?v=LKVYEnu8sLk) using a very early version of the library

> Note: almost none of this is functional right now.  I'm writing this for myself, primarily so I can explore [3D & Advanced Geometry](http://www.geometry.caltech.edu/)

> Also Note: performance is absolutely not a focus at this point.  I'm not sure it'd be a good idea to use this design in production.

### Spectra Features

- Read Metal graphics pipeline objects into a DescriptorManager with the S3DXML format.
- Some classes set up to manage rendering (Renderer, RenderStage) but these will change soon.

### Spectra Roadmap

- Finish the SpectraXML format for defining Model I/O objects.
- Rename S3DXML and possibly split it into a separate framework.
- Set up some basic resource management classes.
- Rewrite Renderer, RenderStage, etc.
- Configure auto-injection for Swinject containers, so users can dynamically define higher order factories as they
  read in XML data (requires Swinject 2.0.0)
- Integrate with MPS Metal Performance Shaders for convolutions, etc.

### Misc Notes

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

### Model I/O for scene graph nodes

I didn't quite realize that MDLMesh/MDLSubmesh pretty much reimplements most of what I was thinking about
- and I didn't understand how the data for Model I/O MDLAssets was formatted
- i can get the submeshes to do most of what i wanted for geometry/mesh manipulation
  - these are basically the dataMaps that i was creating with MeshGenerator's
- it will be fairly easy to wrap MDLAssets in a basic SceneGraph and I don't think i lose any flexibility by using Model I/O
- however, i may want to move the S3DXML stuff to a separate project eventually
  - yet, not until i determine exactly what i want to do with it.  because the last thing i want to do right now is deal with more framework bullshit
  - i would really enjoy playing with shit that renders with lots of colors and lots of flexible vertices and whatnot

i think one thing i lose with MDLMesh and MDLSubmesh is the ability to do MeshCategory/MeshType and define morphisms between them
- admittedly, this is probably a bit too complex to do anyways.
- however, i could still inspect the MDLVertexDescriptor (not the MTL one) that's attached to a MDLMesh
  - and then infer a mesh's applicable 'categories' in order to apply new categories to it
  - applying a new category would mean extending it's submeshes (in the simplest sense) 
    - it could also mean adding new vertices to the mesh (and updating the corresponding submeshes in a way that makes sense)
      - however, updating the submeshes would be more simply defined if there were functions attached to the MDLMesh that defined how to update these
      - and given that it's bad practice to update the MDLMesh class, the only way to do this is by wrapping it
      - and because by wrapping it, it changes the interface to the rest of the Spectra API, this makes this feature too complicated to implement
        - yet, a subclass might work.  or perhaps a D/I function that accepts a mesh and modifies it, regenerating the submeshes
  - see: MDLVertexAttribute Vertex Attributes: E.G. Anisotropy, Binormal, Bitangent, Color, EdgeCrease, Weights, etc..
    - these are similar to the 'categories' that i was thinking about creating anyways
      - yet, getting the generators to interoperate with these might be a bit difficult
- how to interchange b/w MDLVertexAttribute structure of arrays (optimized for flexibility of writing and composability) and array of structures (optimized for reading)
- how to best structure the dependency injection for mesh generators


### Parsing XSD/XML

[Finite State Automata (FSA) Algorithm](http://www.ltg.ed.ac.uk/~ht/XML_Europe_2003.html)

