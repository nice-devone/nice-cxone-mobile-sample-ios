import Swinject
import SwinjectAutoregistration


/// The assembler for all related stuff to the Data layer.
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
