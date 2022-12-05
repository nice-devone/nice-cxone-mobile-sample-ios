import Swinject


class AppModule {

    // MARK: - Properties
    
    private lazy var mainAssembly: Assembly = AppAssembly()
    private(set) lazy var assembler: Assembler = {
        let assembler = Assembler(container: container)
        assembler.apply(assembly: self.mainAssembly)
        return assembler
    }()

    lazy var resolver: Swinject.Resolver = container.synchronize()
    lazy var container = Swinject.Container()
    
    
    // MARK: - Init
    
    init() {
        // Initialize lazy assembler to resolve all dependencies right away
        _ = assembler
    }
}
