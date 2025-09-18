const pow = @import("std").math.pow;
const sqrt = @import("std").math.sqrt;
pub const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn init(x: f64, y: f64, z: f64) Vec3 {
        return Vec3{ .x = x, .y = y, .z = z };
    }

    pub fn dot_product(self: Vec3, other: Vec3) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    /// This method calculates the distance between two Vec3 objects, by following the distance formula in euclidean space.
    pub fn distance(self: Vec3, other: Vec3) f64 {
        const xd = pow(f64, self.x - other.x, 2);
        const yd = pow(f64, self.y - other.y, 2);
        const zd = pow(f64, self.z - other.z, 2);

        return sqrt(xd + yd + zd);
    }

    pub fn twice(self: *Vec3) void {
        self.x = self.x * 2;
        self.y = self.y * 2;
        self.z = self.z * 2;
    }
};
