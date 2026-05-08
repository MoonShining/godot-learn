   shader_type canvas_item;

    // 暴露给编辑器面板的参数
    uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // 描边颜色，默认白色
    uniform float outline_width : hint_range(0.0, 10.0, 0.1) = 1.0; // 描边宽度
    // 描边模式：0=周围8个方向, 1=十字4个方向, 2=菱形4个方向
    uniform int pattern : hint_range(0, 2) = 0;
    // 是否在内部描边（会覆盖边缘一圈图像）
    uniform bool inside = false;
    // 是否启用描边
    uniform bool add_margins = true;

    void vertex() {
        // 如果需要扩充绘制区域以防止描边被裁剪
        if (add_margins) {
            VERTEX += (UV * 2.0 - 1.0) * outline_width;
        }
    }

    bool has_matching_neighbour(vec2 uv, vec2 texture_pixel_size, sampler2D tex) {
        vec2 offsets[8] = {
            vec2(-1, -1), vec2(0, -1), vec2(1, -1),
            vec2(-1, 0),               vec2(1, 0),
            vec2(-1, 1),  vec2(0, 1),  vec2(1, 1)
        };

        for (int i = 0; i < 8; i++) {
            // 根据 pattern 选择采样的方向
            if (pattern == 1 && (i == 0 || i == 2 || i == 5 || i == 7)) continue; // 跳过对角线
            if (pattern == 2 && (i == 1 || i == 3 || i == 4 || i == 6)) continue; // 跳过上下左右

            vec2 sample_uv = uv + offsets[i] * texture_pixel_size * outline_width;
            // 检查邻居的 Alpha 值是否大于阈值 (0.0 表示有颜色)
            if (texture(tex, sample_uv).a > 0.0) {
                return true;
            }
        }
        return false;
    }

    void fragment() {
        vec2 uv = UV;

        // 如果扩充了顶点，需要重新映射 UV 坐标
        if (add_margins) {
            vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(outline_width * 2.0));
            uv = (uv - texture_pixel_size * outline_width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

            if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                COLOR = vec4(0.0);
            } else {
                COLOR = texture(TEXTURE, uv);
            }
        } else {
            COLOR = texture(TEXTURE, uv);
        }

        // 核心描边逻辑
        if ((COLOR.a > 0.0) == inside && has_matching_neighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
            COLOR = outline_color;
            // 如果你想描边有一点透明度，可以保留原图的alpha通道：
            // COLOR.a = outline_color.a;
        }
    }