package app.porto.shared.di

import app.porto.shared.db.PortoDb
import app.porto.shared.prices.PriceRepository
import org.koin.dsl.module

val appModule = module {
    // Database (wired in T4.1 with actual driver)
    single { PortoDb(get()) }

    // Price repository (wired after T1.2)
    single { PriceRepository(get(), get()) }
}
