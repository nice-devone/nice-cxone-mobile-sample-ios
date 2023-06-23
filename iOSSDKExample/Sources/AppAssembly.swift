import Swinject
import SwinjectAutoregistration


/// The application assembler which handles child assemblers with Swinject library.
struct AppAssembly: Assembly {
    
    let dependencies: [Assembly] = [
        PresentationAssembly(),
        DomainAssembly(),
        DataAssembly()
    ]
    
    func assemble(container: Container) {
        dependencies.forEach { $0.assemble(container: container) }
    }
}
