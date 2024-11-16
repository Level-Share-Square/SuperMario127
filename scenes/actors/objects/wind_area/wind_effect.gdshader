shader_type particles;

uniform vec2 size = vec2(64.0, 64.0); // Size of the rectangle
uniform vec4 emission_rect = vec4(0, 64, 64, 1); // Emission rectangle
uniform float wind_speed = 30.0; // Speed of the particles
uniform float alpha = 1.0;
uniform uint seed_input;

float random(inout uint seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
		k = s / 127773;
		s = 16807 * (s - k * 127773) - 2836 * k;
	}
	if  (s < 0) {
		s += 2147483647;
		seed = uint(s);
	}
	return float(seed % uint(65536))/65535.0;
}

float random_m1_p1(inout uint seed) {
	return random(seed)*2.0-1.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	uint base_number = NUMBER;
	uint seed = hash(base_number+seed_input+uint(1)+RANDOM_SEED);
	//EMISSION_TRANSFORM = mat4
	//Check if the particle is outside the area
	if (RESTART) {
		TRANSFORM[3].x = emission_rect.z * random_m1_p1(seed);
		TRANSFORM[3].y = emission_rect.y;
	}
	if (-size.y*2.0+wind_speed > TRANSFORM[3].y){
		//Set the particle opacity
		if (wind_speed/abs(wind_speed) == 1.0){
			if (COLOR.a > 0.0) {
				COLOR.a -= .25;
			}
			else {
				COLOR.a = 0.0;
				ACTIVE = false;
			}
		}
	if (TRANSFORM[3].y > 0.0+wind_speed){
		if (COLOR.a > 0.0) {
			COLOR.a -= .25;
		}
		else {
			COLOR.a = 0.0;
			ACTIVE = false;
		}
	}
	}
	VELOCITY = vec3(0, -wind_speed*20.0, 0);
}