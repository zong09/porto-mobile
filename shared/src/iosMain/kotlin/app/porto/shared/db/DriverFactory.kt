package app.porto.shared.db

import app.porto.db.Porto
import com.squareup.sqldelight.db.SqlDriver
import com.squareup.sqldelight.driver.native.NativeDriver

actual class DriverFactory {
    actual fun getDriver(): SqlDriver {
        return NativeDriver("porto.db")
    }
}
