import Swinject


open class Coordinator {
    
    // MARK: - Properties
    
    public let assembler: Assembler
    /// Convenient access to the `assembler`'s resolver.
    public var resolver: Swinject.Resolver { assembler.resolver }
    
    
    // MARK: - Init
    
    public init(assembler: Assembler) {
        self.assembler = Assembler(parentAssembler: assembler)
    }
}
