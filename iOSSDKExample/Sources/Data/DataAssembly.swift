import Swinject
import SwinjectAutoregistration


struct DataAssembly: Assembly {
    
    // MARK: - Properties
    
    private static weak var container: Container?
    
    
    // MARK: - Init
    
    init() { }
    
    
    // MARK: - Methods
    
    func assemble(container: Container) {
        Self.container = container
    }
    
    static func cleanResetableContainer() {
        Self.container?.resetObjectScope(.resetableContainer)
    }
}
