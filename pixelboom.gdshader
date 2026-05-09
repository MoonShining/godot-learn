    shader_type canvas_item;

    // 爆炸进度：0 表示正常，1 表示完全炸开并消失
    uniform float progress : hint_range(0.0, 1.0) = 0.0;

    // 像素块大小（数值越大块越大）
    uniform float pixel_size : hint_range(1.0, 100.0) = 1.0;

    // 爆炸散开的力度（数值越大飞得越远）
    uniform float explosion_force : hint_range(0.0, 5.0) = 1.1;

    // 伪随机函数：用于给每个方块生成固定的随机值
    float hash(vec2 p) {
        return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
    }

    // 伪随机方向函数：为每个方块生成一个随机的飞行方向
    vec2 hash_dir(vec2 p) {
        float angle = hash(p) * 6.2831853; // 随机角度 0 ~ 2PI
        return vec2(cos(angle), sin(angle));
    }

    void fragment() {
        // 1. 将当前 UV 网格化，获取这个像素属于哪一个“块”
        vec2 grid_uv = floor(UV / (TEXTURE_PIXEL_SIZE * pixel_size)) * (TEXTURE_PIXEL_SIZE * pixel_size);

        // 2. 为当前“块”生成独立的随机属性
        float noise_val = hash(grid_uv);         // 随机值，用于决定消散时间
        vec2 random_dir = hash_dir(grid_uv);     // 随机方向，用于决定飞向哪里

        // 给爆炸方向加一点重力感（可选，向下的倾向）
        // random_dir.y += 0.5;

        // 3. 计算偏移量：进度越大，向随机方向偏移越远
        // 使用 pow(progress, 2.0) 让爆炸有初速度快、后面变慢的减速感
        vec2 offset = random_dir * explosion_force * pow(progress, 1.5);

        // 4. 获取偏移后的 UV（这就是让像素飞出去的核心：我们要去读取偏移之前的颜色）
        // 为了防止采样超出边界（Texture重复），我们在边缘加上限制
        vec2 shifted_uv = UV - offset;

        // 如果偏移后的 UV 超出了原图范围，直接变透明
        if (shifted_uv.x < 0.0 || shifted_uv.x > 1.0 || shifted_uv.y < 0.0 || shifted_uv.y > 1.0) {
            discard;
        }

        // 5. 采样原图在这个偏移位置的颜色
        vec4 tex_color = texture(TEXTURE, shifted_uv);

        // 如果采样的颜色是透明的，直接丢弃
        if (tex_color.a == 0.0) {
            discard;
        }

        // 6. 消散逻辑：爆炸到一定程度后，方块开始消失
        // progress 从 0.5 开始逐渐让方块消失
        float dissolve_threshold = (progress - 0.2) * 1.5;
        if (noise_val < dissolve_threshold) {
            discard;
        }

        COLOR = tex_color;
    }