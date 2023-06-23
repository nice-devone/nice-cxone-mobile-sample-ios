import Swinject


open class Coordinator {
    
    // MARK: - Properties
    
    let assembler: Assembler
    /// Convenient access to the `assembler`'s resolver.
    var resolver: Swinject.Resolver { assembler.resolver }
    
    
    // MARK: - Init
    
    init(assembler: Assembler) {
        self.assembler = Assembler(parentAssembler: assembler)
    }
}
