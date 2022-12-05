import Swinject
import SwinjectAutoregistration


internal struct AppAssembly: Assembly {
    
    let dependencies: [Assembly] = [
        PresentationAssembly(),
        DomainAssembly(),
        DataAssembly()
    ]
    
    func assemble(container: Container) {
        dependencies.forEach { $0.assemble(container: container) }
    }
}
